function diameter_running_corAnalysis(animal, date, run, varargin)
% This function is to build an analyze blood vessel diameter and wheel running
% correlation project folder, create a result in it. To build a result plot
% notebook, you need to run nb_bv_running_cor.m

% Finished at 12/29/2020
parser = inputParser;
addRequired(parser, 'animal', @ischar );
addRequired(parser, 'date', @ischar);
addRequired(parser, 'run', @(x) isnumeric(x) && isscalar(x) && (x>0));
addParameter(parser, 'bvfolder', 'all');
addParameter(parser, 'preBoutSec', 5, @(x) isnumeric(x) && isscalar(x) && (x>0));
addParameter(parser, 'postBoutSec', 10,  @(x) isnumeric(x) && isscalar(x) && (x>0));
parse(parser,animal, date, run, varargin{:});

bvfolder = parser.Results.bvfolder;
prebout = parser.Results.preBoutSec; % unit is sec
postbout = parser.Results.postBoutSec; % unit is sec

bvfilesys = bv_file_system();

runpath = sbxPath(animal, date, run, 'running');
runpath = runpath.result;
runresult = load(runpath);
runresult = runresult.result;
runscanrate = runresult.scanrate;
rundf = get_bout_idx(animal, date, run);

% df = correlation_table_running_bv({animal, date, run;});
% files = unique({df.bvresultfile});
% disp(files);

% choose the subfolder you want to check
bvroot = sbxPath(animal, date, run, 'bv');
if strcmp(bvfolder, 'all')
    subbv = bvroot.layerfolderpath;
else
    subbv = {[bvroot.folderpath, bvfolder]};
end

for i = 1:length(subbv)
    resultpath = [correct_folderpath(subbv{i}), bvfilesys.resultpath];
    bvresult = load(resultpath);
    bvresult = bvresult.result;
    scanrate = bvresult.scanrate;
    result = struct();
    plotr = length(bvresult.roi) + 1;
    plotc = length(rundf);
    individualfig = tiledlayout(plotr,plotc);
    for r = 1:length(bvresult.roi)
        roi = bvresult.roi{r};
        tmpdf = rundf
        tmpidx = [];
        for j = 1:length(tmpdf)
            nexttile
            if isfield(roi, 'id')
                tmpdf(j).roiid = roi.id;
            else
                tmpdf(j).roiid = num2str(r);
            end
            
            startidx = translateIdx(tmpdf(j).startidx, runscanrate, scanrate);
            endidx = postbout * scanrate + startidx - 1;
            %translateIdx(tmpdf(j).endidx, runscanrate, scanrate);
            if endidx > length(roi.diameter)
                disp('endidx out of range. Pass.');
                continue
            end
            
            bv_array = roi.diameter(startidx:endidx);
            
            
            baseline_array = roi.diameter(startidx-prebout*scanrate : startidx-1);
            baseline = mean(baseline_array);
            bv_array_dff = (bv_array - baseline)/baseline;
            baseline_array_dff = (baseline_array - baseline)/baseline;
            
            if baseline > roi.diameter_baseline + roi.diameter_std
                disp('Baseline out of range. Pass.');
                continue
            end
            plot([baseline_array_dff, bv_array_dff]);
            tmpidx = [tmpidx, j];
            tmpdf(j).tissue = roi.tissue;
            tmpdf(j).type = roi.type;
            tmpdf(j).position = roi.position;
            tmpdf(j).bv_scanrate = scanrate;
            if strcmp(subbv{i}(end), '\')
                tmpbvpath = subbv{i}(1:end-1);
            else
                tmpbvpath = subbv{i};
            end
            [~,tmpdf(j).layer] = fileparts(tmpbvpath);
            tmpdf(j).baseline = baseline;
            [tmpdf(j).maxdff, tmpmaxidx] = max(bv_array_dff);
            tmpdf(j).maxdelay = tmpmaxidx/scanrate;
            tmphalfidx = find(bv_array_dff(1:tmpmaxidx) > tmpdf(j).maxdff * 0.5);
            if length(tmphalfidx) > 0
                tmphalfidx = tmphalfidx(1);
                tmpdf(j).halfdelay = tmphalfidx/scanrate;
            else
                sprintf('half delay is equal to max delay at roi %s at bout %d: %s', tmpdf(j).roiid, tmpdf(j).boutid, subbv{i})
                tmpdf(j).halfdelay = tmpdf(j).maxdelay;
            end
            tmpdf(j).bvarray = [baseline_array_dff, bv_array_dff];
            
            
        end
        if isempty(fieldnames(result))
            result = tmpdf(tmpidx);
        else
            result = [result, tmpdf(tmpidx)];
        end
    end
    
    % plot running bout
    for k = 1:length(rundf)
        nexttile
        tmpidxstart = rundf(k).startidx;
        tmprunarray = runresult.array(tmpidxstart-prebout*runscanrate:tmpidxstart+postbout*runscanrate-1);
        plot(tmprunarray);
    end
    analysis_folder = [correct_folderpath(subbv{i}), bvfilesys.bv_running_correlation_folderpath];
    if not(isfolder(analysis_folder))
        mkdir(analysis_folder)
    end
    
    % save result.
    resultpath = [correct_folderpath(subbv{i}), bvfilesys.bv_running_correlation_resultpath];
    save(resultpath,'result');
    individualfigpath = [correct_folderpath(subbv{i}), bvfilesys.bv_running_correlation_individualfigpath];
    saveas(individualfig, individualfigpath);
    close;
    % result2csv(resultpath,{'bvarray'});
    % plot result.
    
end
end


