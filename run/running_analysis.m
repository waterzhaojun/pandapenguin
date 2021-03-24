function result = running_analysis(animal, date, run, varargin)
% 3/23/2021
% In this result struct includes following data:
% 'array' is the original array from quad, the only treat is calculate the
% diff. Without any unit.
% 'secarray': deprecated. I used to bint the ori array to 1hz, but I don't think it is necessary now.
% 'array_treated': the original array may have some treatment, including pretreat like deshake, and treatment in different bout method.
% 'secarray_treated': after the bout method treatment, it will also create
% a 1hz binted data. It should have the same treatment as 'array_treated'.


parser = inputParser;
addRequired(parser, 'animal', @ischar );
addRequired(parser, 'date', @ischar);
addRequired(parser, 'run', @isnumeric); 
addParameter(parser, 'boutMethod', 'drewlab', @ischar);
addParameter(parser, 'saveresult', true, @islogical);
parse(parser, animal, date, run, varargin{:});

boutMethod = parser.Results.boutMethod;
saveresult = parser.Results.saveresult;

filesys = run_file_system();

root = sbxDir(animal, date, run);
root = root.runs{1}.path;
root = correct_folderpath([correct_folderpath(root), filesys.folder]);
if ~exist(root, 'dir')
   mkdir(root);
end

path = sbxPath(animal, date, run, 'quad');
inf = sbxInfo(path, true);
if inf.scanmode == 1
    scanrate = 15.5;
elseif inf.scanmode == 2
    scanrate = 31;
end

cfg = run_config();

result = struct();
result.array = getRunningArray(path);
signalarray =  deshake(result.array) * cfg.blockunit * scanrate;
% result.secarray = bint1D(abs(result.array), floor(scanrate)); % Deprecated.
result.scanrate = scanrate;

result.boutMethod = boutMethod;
if strcmp(boutMethod, 'markov')
    % If use Markov, use below code.
    markov_para_path = [fileparts(which('get_bout_markov')), '\', 'LocoHMM_2state.mat'];
    [result.bout, result.secarray_treated, result.array_treated, result.restbout, result.restidx] = get_bout_markov(signalarray, scanrate, markov_para_path);
elseif strcmp(boutMethod, 'drewlab')
    % If use Drewlab, use below code.
    [result.bout, result.secarray_treated, result.array_treated, result.restbout, result.restidx] = get_bout_drewlab(signalarray, scanrate);
end

result.config = cfg;


plot_running(result, 'detail', true);

if saveresult
    % save plot ========================================================
    saveas(gcf,[root, filesys.responsePath]);
    close;

    % save result ========================================================
    save([root, filesys.resultPath], 'result');
end

end