function hrf_analysis(animal, date, run, varargin)

% Define output path ================================================
% I want to merge the HRF result to the result.mat file as even I rerun
% running_analysis to overwrite the result.mat file, it's not a miss that
% HRF get lost. It need to be rerun anyway. Put them together will easier
% to manage.

parser = inputParser;
addRequired(parser, 'animal');
addRequired(parser, 'date');
addRequired(parser, 'run');
addParameter(parser, 'extra_output_folder', '');
parse(parser, animal, date, run, varargin{:});

extra_output_folder = parser.Results.extra_output_folder;

runresultpath = sbxPath(animal, date, run, 'running');
result = load(runresultpath.result);
result = result.result;
HRF_outputpath = 'HRF_result.mat'; % This path is only useful when save to extra directory.
result.HRF_pic = 'HRF_pic.jpg'; % This file names will only be defined in this function. I may move it to run_file_system.m

restidx = baseline_idx_with_long_term_rest(result);
running_binary = array_binary(result);
%     if length(restidx) == 0
%         continue;
%     end
%     disp('This trial has enough length baseline period');

bvresult = extractBvData(animal, date, run);

for i = 1:length(bvresult)
    corrArrayori = bvresult(i).diameter;

    baseline = mean(corrArrayori(restidx));

    corrArray = (corrArrayori - baseline)/baseline;
    [H,coeff] = train_HRF_model(running_binary, corrArray, result.scanrate);
    result.HRF = struct();
    result.HRF.restidxLength = length(restidx);
    result.HRF.oridiameter = corrArrayori;
    result.HRF.baseline = baseline;
    result.HRF.diameter = corrArray;
    result.HRF.animal = animal;% It is not necessary to put this data here , but it will be easier when extract.
    result.HRF.date = date;% It is not necessary to put this data here , but it will be easier when extract.
    result.HRF.run = run;% It is not necessary to put this data here , but it will be easier when extract.
    result.HRF.A = H(1);
    result.HRF.td = H(2);
    result.HRF.tao = H(3);
    result.HRF.coeff = coeff;
    result.HRF.bvposition = bvresult(i).position;
    result.HRF.bvid = bvresult(i).id;
    result.HRF.bvtype = bvresult(i).type;
    result.HRF.bvtissue = bvresult(i).tissue;
    result.HRF.bvlayer = bvresult(i).layer;
    save(runresultpath, 'result');
    exportgraphics(gcf,[correct_folderpath(runresultpath.folder), result.HRF_pic]);%,'ContentType','vector')
    disp('Done');
end

if ~strcmp(extra_output_folder, '')
    df = result.HRF;
    save([correct_folderpath(extra_output_folder), HRF_outputpath], 'df');
    exportgraphics(gcf,[correct_folderpath(extra_output_folder), result.HRF_pic]);
end


end