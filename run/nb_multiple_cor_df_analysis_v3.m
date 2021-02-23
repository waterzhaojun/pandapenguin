% This notebook is suppose you already finished saving each trial's
% connected correlation data in a root folder (set as below, Each trial is
% a subfolder, and in the folder should have a corr_data.mat).
% To produce each trial's running correlate data, go to use
% "nb_running_correlat_with_other_data.m"

% This notebook arrange the data by roi.

root = 'C:\Users\Levylab\jun\test\';

pathlist = {
    [root, 'CGRP0716_210129_run2', '\corr_data.mat'],...
%     [root, 'CGRP0716_210129_run3', '\corr_data.mat'],...
%     [root, 'CGRP0716_210129_run4', '\corr_data.mat'],...
%     [root, 'CGRP0716_210129_run5', '\corr_data.mat'],...
%     [root, 'CGRP0716_210129_run7', '\corr_data.mat'],...
%     [root, 'CGRP0716_210129_run8', '\corr_data.mat'],...
%     [root, 'WT0119_201125_run1', '\corr_data.mat'],...
%     [root, 'WT0119_201125_run2', '\corr_data.mat'],...
%     [root, 'WT0119_201125_run3', '\corr_data.mat']...
%     [root, 'WT0119_201125_run5', '\corr_data.mat']...
};


for i = 1:length(pathlist)
    tmp = load(pathlist{i});
    tmp = tmp.df;
    if i == 1
        df = tmp;
    else
        
        df = [df;tmp];
    end
    
end

% plot multiple bout fig.
c = 4;
r = 4;
plotidx = 1;
boutID = unique({df.runningboutID});
timecourseLength = length(df(1).runningcorArray);
arate = df(1).runningscanrate;
preBoutSec = 3; %df(1).runningpreBoutSec;
postBoutSec = 5; %df(1).runningpostBoutSec;

for i = 1:length(boutID)
    theboutID = boutID{i};
    subdf = df(strcmp({df.runningboutID}, theboutID));
    subbvmx = reshape([subdf.bv_diameter_bout_timecourse_realvalue], timecourseLength, []);
    subbvrawmx = reshape([subdf.bv_diameterRaw_bout_timecourse_realvalue], timecourseLength, []);
    
    if plotidx == 1
        figure('Position', [10 10 2000 2000]);
        tiledlayout(r,c)
        starti = i;
    end
    nexttile %vFor treated data=====================================
    yyaxis left
    plot(subbvmx);
    bvresponse_legend = {};
    % format the legend text
    for tmplegendi = 1:length(subdf)
        bvresponse_legend{tmplegendi} = [subdf(tmplegendi).bv_id, ' (', subdf(tmplegendi).bv_tissue, ' ', subdf(tmplegendi).bv_type, ' ', num2str(round(subdf(tmplegendi).bv_diameter_bout_baseline)),')'];
    end
    bvresponse_legend{length(bvresponse_legend)+1} = ['running']
    
    
    xticks(1:arate:timecourseLength);
    xticklabels([]);
    title('Diameter responses');
    ylabel('diameter (um)');
    ylim([10, 40]);
%     ylabel('RFF');
%     ytickformat('percentage')

    yyaxis right
    bar(subdf(1).runningcorArray, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    xticks(1:arate:timecourseLength);
    xticklabels(-preBoutSec:1:postBoutSec);
    xlabel('time course (sec)');
    ylabel('speed (m/s)');
    title(strrep(subdf(1).runningboutID, '_', '\_'));
    legend(bvresponse_legend, 'location', 'southoutside', 'orientation', 'horizontal');
    
    nexttile %vFor raw data=====================================
    yyaxis left
    plot(subbvrawmx);
    xticks(1:arate:timecourseLength);
    xticklabels([]);
    title('Diameter raw responses');
    ylabel('diameter (um)');
    ylim([10,40]);
%     ytickformat('percentage')
    
    yyaxis right
    bar(subdf(1).runningcorRawArray, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
    xticks(1:arate:timecourseLength);
    xticklabels(-preBoutSec:1:postBoutSec);
    xlabel('time course (sec)');
    ylabel('speed (m/s)');
    title(strrep(subdf(1).runningboutID, '_', '\_'));
    
    % ========================================================
    if rem(i, c*r/2) == 0 || i == length(boutID)
        plotidx = 1;
        endi = i;
%         exportgraphics(gcf,[root, num2str(starti), ' to ', num2str(endi), ' bout shape.pdf'],'ContentType','vector')
%         close;
    else
        plotidx = plotidx + 1;
    end
end