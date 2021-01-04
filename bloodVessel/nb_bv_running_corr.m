%%% blood vessel wheel running correlation notebook
%
%
%
%
%% Information
%
% Set the bv layer folder path here:
path = 'D:\2P\CGRP03\201109_CGRP03\201109_CGRP03_run4\bv\6to7';

% Set related parameters here: these is only realted with plot, it won't
% effect the analysis value.
prebout_length = 3;  % second. the time period before each bout as baseline period.
postbout_length = 5; % second. The time period after start of each bout as response period.

%%
% Don't change any code below===============================
% load data
[animal, date, run] = pathTranslate(path);

path = correct_folderpath(path);
bvfilesys = bv_file_system();
resultpath = [path, bvfilesys.resultpath];
result = load(resultpath);
result = result.result;
ref = read(Tiff([path, bvfilesys.refpath],'r'));

runfilepath = sbxPath(animal,date,run,'running');
runresult = load(runfilepath.result);
runresult = runresult.result;

runbvcorrpath = [correct_folderpath(path), bvfilesys.bv_running_correlation_resultpath];
runbvresult = load(runbvcorrpath);
runbvresult = runbvresult.result;


% plot data by id.


for i = 1:length(result.roi)
    roiid = i;   % change to id in the future
    roi = result.roi{i};
    subref = addroi(ref, roi.BW);
    subrunbvresult = runbvresult([runbvresult.roiid] == roiid);  % If it is string, it may need change.
    disp(['roi id: ', roiid]);
    disp(['baseline diameter: ', num2str(roi.diameter_baseline)]);
    
    for j = 1:length(subrunbvresult)
        tmp = reshape(subrunbvresult(j).bvarray, [],1);
        if j == 1
            mx = tmp;
        else
            mx = cat(2,mx,tmp);
        end
    end
    subplot(2,2,1);
    imshow(subref);
    
    subplot(2,2,2);
    plot_running(runresult);
    hold on
    yline(roi.diameter_baseline, 'color', 'blue');
    yline(roi.diameter_baseline + roi.diameter_std, 'color', 'green');
    yline(roi.diameter_baseline - roi.diameter_std, 'color', 'green')
    plot(bint1D(roi.diameter, result.scanrate));
    xticks([0:5*60:length(roi.diameter)]);
    xticklabels([0:5:length(roi.diameter)/60]);
    xlabel('time course (min)');
    hold off
    
    subplot(2,2,3);
    plot(mx * 100);
    ylabel('diameter dff changes');
    ytickformat('percentage');
    xlabel('time course (min)');
    xticks(1:size(mx,1));
    xticklabels([-prebout_length:postbout_length-1]);
    xline(prebout_length+1);
    
    subplot(2,2,4);
    scatter([subrunbvresult.maxspeed], [subrunbvresult.maxdff] * 100);
    ylabel('diameter max dff changes');
    xlabel('bout max speed (block/sec)');
    ytickformat('percentage');
end



