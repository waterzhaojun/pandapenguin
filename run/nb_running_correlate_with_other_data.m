% This notebook is to analyse running and related data responses

animal = 'WT0118';
date = '201123';
run = 1;
preBoutSec = 3;  % Analyse 3s before start of the bout.
postBoutSec = 5; % Analyse 5s after the start of the bout.

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
subplot(6,1,1);
plot(regdata.trans_x);
title('trans_x');
subplot(6,1,2);
plot(regdata.trans_y);
title('trans_y');
subplot(6,1,3);
plot(regdata.scale_x);
title('scale_x');
subplot(6,1,4);
plot(regdata.scale_y);
title('scale_y');
subplot(6,1,5);
plot(regdata.shear_x);
title('shear_x');
subplot(6,1,6);
plot(regdata.shear_y);
title('shear_y');

% Plot multiple timecourse.
timecourseLength = 120;
anaField = 'reg_trans_x_bout_timecourse'
mx = reshape([df.(anaField)], timecourseLength, []);
plot(mx);
xticks(0:15:timecourseLength);
xticklabels(-preBoutSec:postBoutSec);
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
runningCorrelationPlot(...
    rundata, {bvdata, regdata}, ...
    {{'diameter'},{'trans_x', 'trans_y', 'scale_x', 'scale_y', 'shear_x', 'shear_y'}}, ...
    {'layer','layer'}...
)