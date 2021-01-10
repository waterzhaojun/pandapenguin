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
addParameter(parser, 'preBoutSec', 3, @(x) isnumeric(x) && isscalar(x) && (x>0));
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
    for r = 1:length(bvresult.roi)
        roi = bvresult.roi{r};
        tmpdf = rundf;
        tmpidx = [];
        for j = 1:length(tmpdf)
            startidx = translateIdx(tmpdf(j).startidx, runscanrate, scanrate);
            endidx = translateIdx(tmpdf(j).endidx, runscanrate, scanrate);
            if endidx > length(roi.diameter)
                continue
            end
            bv_array = roi.diameter(startidx:endidx);
            baseline = mean(roi.diameter(startidx-prebout*scanrate : startidx-1));
            if baseline < roi.diameter_baseline + roi.diameter_std
                tmpidx = [tmpidx, j];
                tmpdf(j).tissue = roi.tissue;
                tmpdf(j).type = roi.type;
                tmpdf(j).bv_scanrate = scanrate;
                tmp = strsplit(subbv{i}, '\');
                tmpdf(j).layer = tmp(end);
                tmpdf(j).baseline = baseline;
                tmpdf(j).maxdff = (max(bv_array)-baseline)/baseline;
                [~,tmpmaxidx] = max(bv_array);
                tmpdf(j).maxdelay = tmpmaxidx/scanrate;
                tmphalfidx = find(bv_array(1:tmpmaxidx) > tmpdf(j).maxdff * 0.5);
                tmphalfidx = tmphalfidx(1);
                tmpdf(j).halfdelay = tmphalfidx/scanrate;
                
                tmpdf(j).bvarray = (roi.diameter(startidx - prebout*scanrate : startidx + postbout*scanrate-1)-baseline)/baseline;
                if isfield(roi, 'id')
                    tmpdf(j).roiid = roi.id;
                else
                    tmpdf(j).roiid = r;
                end
            else
                disp('Baseline out of range. Pass.');
            end
        end
        if ~exist('result','var')
            result = tmpdf(tmpidx);
        else
            result = [result, tmpdf(tmpidx)];
        end
    end
    analysis_folder = [correct_folderpath(subbv{i}), bvfilesys.bv_running_correlation_folderpath];
    if not(isfolder(analysis_folder))
        mkdir(analysis_folder)
    end
    
    % save result.
    save([correct_folderpath(subbv{i}), bvfilesys.bv_running_correlation_resultpath],'result');
    
    % plot result.
    
end
end


