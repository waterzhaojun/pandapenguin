% This notebook is to analyse running and related data responses

animal = '';
date = '';
run = '';
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
plot_correlation(

% This part is to check the plot of single trials correlation. 
runningCorrelationPlot(...
    rundata, {bvdata, regdata}, ...
    {{'diameter'},{'trans_x', 'trans_y'}}, ...
    {'layer','layer'}...
)