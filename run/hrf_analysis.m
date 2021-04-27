function meanCoeff = hrf_analysis(animal, date, run, varargin)

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
addParameter(parser, 'duration_range', nan); 
% To use 'duration_range' to remove some period don't want to train, define the variable 
% like [0, 5, 20, 30]. The first two elements is to tell I want the
% locomotion that last from 0 to 5 sec. If the bout not qualified, remove
% the bout and pre 20 timepoints (3rd element) and post 30 timepoints (4th
% element).

parse(parser, animal, date, run, varargin{:});

duration_range = parser.Results.duration_range;
extra_output_folder = parser.Results.extra_output_folder;

runresultpath = sbxPath(animal, date, run, 'running');
result = load(runresultpath.result);
result = result.result;
HRF_outputpath = 'HRF_result.mat'; % This path is only useful when save to extra directory.
result.HRF_pic = 'HRF_pic.fig'; % This file names will only be defined in this function. I may move it to run_file_system.m

%restidx = baseline_idx_with_long_term_rest(result); % I think this function is not
%trustable.
restidx = result.restidx;
running_binary = array_binary(result);
%     if length(restidx) == 0
%         continue;
%     end
%     disp('This trial has enough length baseline period');

% This part is to build an state binary array that define the period wanted
% to be used to training.
training_binary = ones(1, length(running_binary));
if ~isnan(duration_range)
    for i = 1:length(result.bout)
        tmpbout = result.bout{i};
%         max(tmpbout.startidx - duration_range(3),0)
%         min(tmpbout.endidx + duration_range(4), length(running_binary))
        if tmpbout.duration < duration_range(1) || tmpbout.duration > duration_range(2)
            disp(['Bout ', num2str(i), ' duration is ', num2str(tmpbout.duration), '. Exclude it from training']);
            training_binary(max(tmpbout.startidx - duration_range(3),1) : min(tmpbout.endidx + duration_range(4), length(running_binary))) = 0;
        end
    end
end
training_idx = find(training_binary == 1);

bvresult = extractBvData(animal, date, run);
result.HRF = struct();


figure('Position', [10 10 1000 500*length(bvresult)])
tiledlayout(length(bvresult),4);

for i = 1:length(bvresult)
    corrArrayori = bvresult(i).diameter;

    baseline = median(corrArrayori(restidx));

    corrArray = (corrArrayori - baseline)/baseline;
    nexttile([1,3]);
    [H,coeff] = HRF_train(running_binary(training_idx), corrArray(training_idx), result.scanrate);
    
    title([bvresult(i).id, ' (', bvresult(i).tissue, ' ', bvresult(i).type, '), Coeff = ', num2str(coeff)])
    
    nexttile;
    % This figure is a sample of the trained HRF model by appling -0.5 sec to 3 sec.
    HRF_plot(H,ceil(3*result.scanrate), floor(0.5*result.scanrate), result.scanrate);
    
    result.HRF(i).restidxLength = length(restidx);
    result.HRF(i).oridiameter = corrArrayori;
    result.HRF(i).baseline = baseline;
    result.HRF(i).diameter = corrArray;
    result.HRF(i).animal = animal;% It is not necessary to put this data here , but it will be easier when extract.
    result.HRF(i).date = date;% It is not necessary to put this data here , but it will be easier when extract.
    result.HRF(i).run = run;% It is not necessary to put this data here , but it will be easier when extract.
    result.HRF(i).A = H(1);
    result.HRF(i).td = H(2);
    result.HRF(i).tao = H(3);
    result.HRF(i).coeff = coeff;
    result.HRF(i).bvposition = bvresult(i).position;
    result.HRF(i).bvid = bvresult(i).id;
    result.HRF(i).bvtype = bvresult(i).type;
    result.HRF(i).bvtissue = bvresult(i).tissue;
    result.HRF(i).bvlayer = bvresult(i).layer;
    
end

save(runresultpath.result, 'result');
savefig([correct_folderpath(runresultpath.folder), result.HRF_pic]);
%exportgraphics(gcf,[correct_folderpath(runresultpath.folder), result.HRF_pic]);%,'ContentType','vector')
disp('Done');

if ~strcmp(extra_output_folder, '')
    df = result.HRF;
    save([correct_folderpath(extra_output_folder), animal, '_', date, '_', num2str(run), '_', HRF_outputpath], 'df');
    copyfile([correct_folderpath(runresultpath.folder), result.HRF_pic], ...
        [correct_folderpath(extra_output_folder), animal, '_', date, '_', num2str(run), '_', result.HRF_pic]);
    %exportgraphics(gcf,[correct_folderpath(extra_output_folder), animal, '_', date, '_', num2str(run), '_', result.HRF_pic]);
end

close;

meanCoeff = mean([result.HRF.coeff]);

end