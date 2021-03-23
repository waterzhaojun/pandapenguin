function result = running_analysis(animal, date, run, varargin)
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
result.array = getRunningArray(path, 'deshake', true) * cfg.blockunit * scanrate;
result.secarray = bint1D(abs(result.array), floor(scanrate));
result.scanrate = scanrate;

result.boutMethod = boutMethod;
if strcmp(boutMethod, 'markov')
    % If use Markov, use below code.
    markov_para_path = [fileparts(which('get_bout_markov')), '\', 'LocoHMM_2state.mat'];
    [result.bout, result.secarray_treated, result.array_treated, result.restbout, result.restidx] = get_bout_markov(result.array, scanrate, markov_para_path);
elseif strcmp(boutMethod, 'drewlab')
    % If use Drewlab, use below code.
    [result.bout, result.secarray_treated, result.array_treated, result.restbout, result.restidx] = get_bout_drewlab(result.array, scanrate);
end

result.config = cfg;


plot_running_realfs(result);

if saveresult
    % save plot ========================================================
    saveas(gcf,[root, filesys.responsePath]);
    close;

    % save result ========================================================
    save([root, filesys.resultPath], 'result');
end

end