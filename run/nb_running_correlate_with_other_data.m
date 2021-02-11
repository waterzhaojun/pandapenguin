% This notebook is to analyse running and related data responses

animal = 'CGRP0716';%'WT0118';
date = '210129';%'201123';
run = 4;%1;
preBoutSec = 3;  % Analyse 3s before start of the bout.
postBoutSec = 5; % Analyse 5s after the start of the bout.
report_root = ['C:\Users\jzhao1\Desktop\corr\', animal, '_', date, '_', num2str(run), '\'];

runoridatapath = sbxPath(animal, date, run, 'running');
runoridata=load(runoridatapath.result);
runoridata = runoridata.result;
rundata = extractRunningData(animal, date, run, preBoutSec, postBoutSec);
bvdata = extractBvData(animal, date, run);
regdata = extractAndyRegData(animal, date, run);

% This part is to build struct array for further analysis.
df = runningCorrelationAnalysis(...
    rundata, {bvdata, regdata}, ...
    {'bv_', 'reg_'}, ...
    {{'diameter'}, {'trans_x', 'trans_y', 'scale_x', 'scale_y', 'shear_x', 'shear_y'}}...
);

% This part is to should some interested plot
x_columns = {'runningmaxspeed', 'runningmaxspeed_delay', 'runningduration', 'runningdistance', 'runningacceleration',...
    'runningspeed'...
};
y_columns = {'bv_diameter_bout_max_response', 'bv_diameter_bout_max_response_delay', 'bv_diameter_bout_average_response',...
    'reg_trans_x_bout_max_response', 'reg_trans_x_bout_max_response_delay', 'reg_trans_x_bout_average_response',...
    'reg_trans_y_bout_max_response', 'reg_trans_y_bout_max_response_delay', 'reg_trans_y_bout_average_response',...
    'reg_scale_x_bout_max_response', 'reg_scale_x_bout_max_response_delay', 'reg_scale_x_bout_average_response',...
    'reg_scale_y_bout_max_response', 'reg_scale_y_bout_max_response_delay', 'reg_scale_y_bout_average_response',...
    'reg_shear_x_bout_max_response', 'reg_shear_x_bout_max_response_delay', 'reg_shear_x_bout_average_response',...
    'reg_shear_y_bout_max_response', 'reg_shear_y_bout_max_response_delay', 'reg_shear_y_bout_average_response',...
};
idx = 1;
res = {};
for i = 1:length(x_columns)
    for j = 1:length(y_columns)
        subplot(length(y_columns), length(x_columns), idx);
        corr = analysis_correlation(df, x_columns{i}, y_columns{j}, false);
        res{j,i} = corr{2,4};
        idx = idx + 1;
    end
end
% res = cell2table(res);
% res.Properties.VariableNames = x_columns;
% res.Properties.RowNames = y_columns;
% heatmap(res, 'runningmaxspeed', 'bv_diameter_bout_max_response');
coefdata = cell2mat(res);
coefplot = heatmap(coefdata);
coefplot.XDisplayLabels=x_columns;
coefplot.YDisplayLabels=y_columns;

% Plot alignment.
alen = length(runoridata.array_treated);
arate = runoridata.scanrate;
subplot(7,1,1);
plot(regdata.trans_x);
title('trans\_x');
xticks(1:arate*60:alen);
xticklabels([]);

subplot(7,1,2);
plot(regdata.trans_y);
title('trans\_y');
xticks(1:arate*60:alen);
xticklabels([]);

subplot(7,1,3);
plot(regdata.scale_x);
title('scale\_x');
xticks(1:arate*60:alen);
xticklabels([]);

subplot(7,1,4);
plot(regdata.scale_y);
title('scale\_y');
xticks(1:arate*60:alen);
xticklabels([]);

subplot(7,1,5);
plot(regdata.shear_x);
title('shear\_x');
xticks(1:arate*60:alen);
xticklabels([]);

subplot(7,1,6);
plot(regdata.shear_y);
title('shear\_y');
xticks(1:arate*60:alen);
xticklabels([]);

subplot(7,1,7);
plot(runoridata.array_treated);
title('running');
ylabel('speed (m/sec)');
xlabel('timecourse (min)');
xticks(1:arate*60:alen);
xticklabels(0:1:floor(alen/arate/60));

saveas(gcf,[report_root, 'running deformation corr.pdf'])
close;

% Plot multiple timecourse.
timecourseLength = length(df(1).runningcorArray);
boutID = unique({df.runningboutID});
bvIDs = unique({df.bv_id});
anaFields = {
    'reg_shear_x_bout_timecourse', 'reg_shear_y_bout_timecourse',...
    'reg_trans_x_bout_timecourse', 'reg_trans_y_bout_timecourse',...
    'reg_scale_x_bout_timecourse', 'reg_scale_y_bout_timecourse',...
};
for i = 1:length(boutID)
    theboutID = boutID{i};
    subdf = df(strcmp({df.runningboutID}, theboutID));
    for j =1:length( anaFields)
        anaField = anaFields{j};
        mx = reshape([subdf.(anaField)], timecourseLength, []);
        subplot(2,1,1);
        plot(mx);
        xticks(1:arate:timecourseLength);
        xticklabels([]);
        title(join(strsplit(anaField, '_'), ' '));
        subplot(2,1,2);
        plot(subdf(1).runningcorArray);
        xticks(1:arate:timecourseLength);
        xticklabels(-preBoutSec:1:postBoutSec);
        xlabel('time course (sec)');
        ylabel('speed (m/s)');
        title('Running');
        tmp = strsplit(anaField,'_');
        deform_foldername = join({tmp{2:3}}, '_');
        deform_foldername = [report_root, deform_foldername{1}, '\'];
        if ~exist(deform_foldername, 'dir')
            mkdir(deform_foldername)
        end
        saveas(gcf,[deform_foldername, 'running ', anaField, ' in bout ', num2str(i), '.pdf']);
        close;
    end
end


bvfolder = [report_root, 'diameter_response', '\'];
if ~exist(bvfolder, 'dir')
    mkdir(bvfolder);
end
for i = 1:length(boutID)
    theboutID = boutID{i};
    subdf = df(strcmp({df.runningboutID}, theboutID));
    subbvmx = reshape([subdf.bv_diameter_bout_timecourse], timecourseLength, []);
    subplot(2,1,1)
    plot(subbvmx * 100);
    xticks(1:arate:timecourseLength);
    xticklabels([]);
    title('Diameter responses');
    ylabel('RFF');
    ytickformat('percentage')
    
    subplot(2,1,2)
    plot(subdf(1).runningcorArray);
    xticks(1:arate:timecourseLength);
    xticklabels(-preBoutSec:1:postBoutSec);
    xlabel('time course (sec)');
    ylabel('speed (m/s)');
    title('Running');
    
    saveas(gcf,[bvfolder, 'bout ', num2str(i), ' diameter response.pdf']);
    close;
end

xticks(1:arate:timecourseLength);
xticklabels(-preBoutSec:1:floor(timecourseLength/arate)-preBoutSec);
xlabel('time course (sec)');
ylabel('pixel movement');
title(anaField);

% Plot of the average timecourse.
anaField = 'reg_trans_x_bout_timecourse'
mx = reshape([df.(anaField)], timecourseLength, []);
avg = mean(mx,2);
stderr = std(mx,0,2)/sqrt(size(mx,2));
errorbar([1:length(avg)], avg, stderr);
xticks(0:15:timecourseLength);
xticklabels(-preBoutSec:postBoutSec);
xlabel('time course (sec)');
ylabel('pixel movement');
title(anaField);


% This part is to check the plot of single trials correlation. 
% To check deformation corr, we only need df from one bv id.
subdf = df(strcmp({df.bv_id}, bvIDs{1}));
runningChar={'runningspeed', 'runningmaxspeed', 'runningacceleration',...
    'runningduration', 'runningdistance'};
responseChar = {
    'reg_trans_x_bout_max_response', 'reg_trans_y_bout_max_response',...
    'reg_scale_x_bout_max_response', 'reg_scale_y_bout_max_response',...
    'reg_shear_x_bout_max_response', 'reg_shear_y_bout_max_response',...
};
corrfolder = [report_root, 'correlation', '\'];
if ~exist(corrfolder, 'dir')
    mkdir(corrfolder);
end
for i = 1:length(responseChar)
    idx = 1;
    for j = 1:length(runningChar)
        subplot(3, 2, idx);
        corr = analysis_correlation(df, runningChar{j}, responseChar{i}, true);
        res{i,j} = corr{2,4};
        idx = idx + 1;
    end
    saveas(gcf,[corrfolder, runningChar{j}, ' vs ', responseChar{i},'.pdf']);
    close;
end
coefdata = cell2mat(res);
coefplot = heatmap(coefdata);
coefplot.XDisplayLabels=x_columns;
coefplot.YDisplayLabels=y_columns;
saveas(gcf,[corrfolder, 'P value of running vs deformation.pdf']);
close;
     
r = length(bvdata) + 1;
for i = 1:length(bvdata)
    subplot(r, 1, i);
    plot(bvdata(i).diameter);
    ylabel('diameter (um)');
    title([bvdata(i).tissue,' ', bvdata(i).type, ' ', bvdata(i).id]);
    xticks(1:arate*60:alen);
    xticklabels([]);
end
subplot(r,1,r);
plot(runoridata.array_treated);
title('running');
ylabel('speed (m/sec)');
xlabel('timecourse (min)');
xticks(1:arate*60:alen);
xticklabels(0:1:floor(alen/arate/60));
saveas(gcf,[report_root, 'running bv diameter corr.pdf'])
close;




runningCorrelationPlot(...
    rundata, {bvdata, regdata}, ...
    {{'diameter'},{'trans_x', 'trans_y', 'scale_x', 'scale_y', 'shear_x', 'shear_y'}}, ...
    {'layer','layer'}...
)