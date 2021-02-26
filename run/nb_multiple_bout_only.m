root = 'C:\Users\Levylab\jun\test\';

pathlist = {
%     [root, 'CGRP0720_210224_run1', '\corr_data.mat'],...
    [root, 'CGRP0720_210224_run2', '\corr_data.mat'],...
    [root, 'CGRP0720_210224_run3', '\corr_data.mat'],...
    [root, 'CGRP0720_210224_run4', '\corr_data.mat'],...
    [root, 'CGRP0720_210224_run5', '\corr_data.mat'],...
    [root, 'CGRP0720_210224_run6', '\corr_data.mat'],...
    [root, 'CGRP0720_210224_run7', '\corr_data.mat'],...
    [root, 'CGRP0720_210224_run8', '\corr_data.mat'],...
    [root, 'CGRP0720_210224_run9', '\corr_data.mat'],...
    [root, 'CGRP0720_210224_run10', '\corr_data.mat'],...
%     [root, 'CGRP0720_210222_run9', '\corr_data.mat'],...
%     [root, 'CGRP0716_210129_run4', '\corr_data.mat'],...
%     [root, 'CGRP0716_210129_run5', '\corr_data.mat'],...
%     [root, 'CGRP0716_210129_run7', '\corr_data.mat'],...
%     [root, 'CGRP0716_210129_run8', '\corr_data.mat'],...
%     [root, 'WT0119_201125_run1', '\corr_data.mat'],...
%     [root, 'WT0119_201125_run2', '\corr_data.mat'],...
%     [root, 'WT0119_201125_run3', '\corr_data.mat']...
    %[root, 'WT0119_201125_run5', '\corr_data.mat']...
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
   
    
    if plotidx == 1
        figure('Position', [10 10 1200 1600]);
    end
    subplot(r,c,plotidx);

    plot(subdf(1).runningcorArray);
    xticks(1:arate:timecourseLength);
    xticklabels(-preBoutSec:1:postBoutSec);
    xlabel('time course (sec)');
    ylabel('speed (m/s)');
    title(strrep(subdf(1).runningboutID, '_', '\_'));
    
    if rem(i, c*r) == 0 || i == length(boutID)
        plotidx = 1;
        exportgraphics(gcf,[root, num2str(i-c*r/2+1), ' to ', num2str(i), ' bout shape.pdf'],'ContentType','vector')
        close;
    else
        plotidx = plotidx + 1;
    end
end