function diameter_calculate_baseline(folder, varargin)
% This function is to calcuate diameter baseline based on animal running
% situation. Only use data when animal is in rest period.
% This function should run after did running_analysis.
% I think it is just a tempery version. I need to build a version based on
% time course gradual changes. And also usable for anesthetized animal.
parser = inputParser;
addRequired(parser, 'folder', @ischar );
parse(parser,folder,varargin{:});

folder = correct_folderpath(folder);
bvfilesys = bv_file_system();
resultpath = [folder, bvfilesys.resultpath];
result = load(resultpath);
result = result.result;

% Load running data
[animal, date, run] = pathTranslate(folder);
runresultpath = sbxPath(animal, date, run, 'running');
runresult = load(runresultpath.result);
runresult = runresult.result;
rest_binary = logical(bint1D(runresult.rest.binary_array, runresult.scanrate/result.scanrate, 'method','min'));

for i = 1:length(result.roi)
    bv_value = result.roi{i}.diameter;
    rest_diameter = bv_value(rest_binary);
    result.roi{i}.diameter_baseline = mean(rest_diameter);
    result.roi{i}.diameter_std = std(rest_diameter);
end

save(resultpath, 'result');

end