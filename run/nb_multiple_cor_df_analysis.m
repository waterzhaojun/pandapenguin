root = 'D:\\test\';

pathlist = {
    [root, 'CGRP0716_210129_run2', '\corr_data.mat'],...
    [root, 'CGRP0716_210129_run3', '\corr_data.mat'],...
    [root, 'CGRP0716_210129_run4', '\corr_data.mat'],...
    [root, 'CGRP0716_210129_run5', '\corr_data.mat'],...
    [root, 'CGRP0716_210129_run7', '\corr_data.mat'],...
    [root, 'CGRP0716_210129_run8', '\corr_data.mat'],...
    [root, 'WT0119_201125_run1', '\corr_data.mat'],...
    [root, 'WT0119_201125_run2', '\corr_data.mat'],...
    [root, 'WT0119_201125_run3', '\corr_data.mat']...
    %[root, 'WT0119_201125_run5', '\corr_data.mat']...
};

preBoutSec = 3;
postBoutSec = 5;

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
c = 3;
r = 4;
plotidx = 1;
boutID = unique({df.runningboutID});
timecourseLength = length(df(1).runningcorArray);
arate = df(1).runningscanrate;

for i = 1:length(boutID)
    theboutID = boutID{i};
    subdf = df(strcmp({df.runningboutID}, theboutID));
    subbvmx = reshape([subdf.bv_diameter_bout_timecourse], timecourseLength, []);
    
    if plotidx == 1
        figure('Position', [10 10 1200 1600]);
    end
    subplot(r,c,floor((plotidx-1)/3)*6 + rem((plotidx-1), 3) + 1);
    plot(subbvmx * 100);
    bvresponse_legend = {};
    % format the legend text
    for tmplegendi = 1:length(subdf)
        bvresponse_legend{tmplegendi} = [subdf(tmplegendi).bv_id, ' (', subdf(tmplegendi).bv_tissue, ' ', subdf(tmplegendi).bv_type, ' ', num2str(round(subdf(tmplegendi).bv_diameter_bout_baseline)),')'];
    end
    legend(bvresponse_legend, 'location', 'southoutside', 'orientation', 'horizontal');
    xticks(1:arate:timecourseLength);
    xticklabels([]);
    title('Diameter responses');
    ylabel('RFF');
    ytickformat('percentage')

    subplot(r,c,floor((plotidx-1)/3)*6 + rem(plotidx-1, 3) + 4);
    plot(subdf(1).runningcorArray);
    xticks(1:arate:timecourseLength);
    xticklabels(-preBoutSec:1:postBoutSec);
    xlabel('time course (sec)');
    ylabel('speed (m/s)');
    title(strrep(subdf(1).runningboutID, '_', '\_'));
    
    if rem(i, c*r/2) == 0 || i == length(boutID)
        plotidx = 1;
        exportgraphics(gcf,[root, num2str(i-c*r/2+1), ' to ', num2str(i), ' bout shape.pdf'],'ContentType','vector')
        close;
    else
        plotidx = plotidx + 1;
    end
end