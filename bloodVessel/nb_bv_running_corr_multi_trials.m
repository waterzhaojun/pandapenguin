%% Multi-trial wheel running blood vessel diameter correlation analysis
% This notebook is to do wheel running blood vessel diameter correlation
% analysis. Create a csv file containing a list of result.mat files you
% want to included into your analysis. Each row is one file.

%% setting related parameters
filelistpath = 'D:\Jun\tmp\aaa.csv' % <==========set the csv file list path here
yfield = {'maxdff','maxdelay','halfdelay'}; % <==========set the fields for correlation y.
xfield = {'speed','acceleration','maxspeed','distance','duration'}; % <==========set the fields for correlation x.
filter = ''; % <=======set the filter.


df = combine_data_from_csv_list(filelistpath);
% Included trials:
disp(filelistpath);
sprintf('Total bouts: %d', length(df))

%% Plot the correlation figure.
totalfig = length(yfield) * length(xfield);
c = 2;
r = ceil(totalfig/c);
for i= 1:length(yfield)
    for j = 1:length(xfield)
        y = [df.(yfield{i})];
        x = [df.(xfield{j})];
        subplot(r,c, (i-1)*length(xfield)+j);
        scatter(x,y);
        ylabel(yfield{i});
        xlabel(xfield{j});
    end
end
