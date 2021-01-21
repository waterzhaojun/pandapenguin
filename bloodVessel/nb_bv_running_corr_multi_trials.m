%% Multi-trial wheel running blood vessel diameter correlation analysis
% This notebook is to do wheel running blood vessel diameter correlation
% analysis. Create a csv file containing a list of result.mat files you
% want to included into your analysis. Each row is one file.

%% setting related parameters

% Group A and Group B info
group_A_filelistpath = 'C:\Users\Levylab\Documents\Jun\workingfolder\CGRP.csv' % <==========set the csv file list path here
group_A_name = 'CGRP';
group_A_value = 0;
group_B_filelistpath = 'C:\Users\Levylab\Documents\Jun\workingfolder\WT.csv' % <==========set the csv file list path here
group_B_name = 'WT';
group_B_value = 1;
yfield = {'maxdff'};%,'maxdelay','halfdelay'}; % <==========set the fields for correlation y.
xfield = {'speed','acceleration','maxspeed','distance','duration'}; % <==========set the fields for correlation x.

% Extract result and set filter
dfa = combine_data_from_csv_list(group_A_filelistpath);
dfa = dfa(strcmpi({dfa.position}, 'horizontal'));
dfa = dfa(strcmpi({dfa.type}, 'artery'));
%dfa = dfa([dfa.direction]== 1);

dfb = combine_data_from_csv_list(group_B_filelistpath);
dfb = dfb(strcmpi({dfb.position}, 'horizontal'));
dfb = dfb(strcmpi({dfb.type}, 'artery'));
%dfb = dfb([dfb.direction]== 1);
for i = 1:length(dfb)
    if dfb(i).bv_scanrate > 1
        dfb(i).bvarray = bint1D(dfb(i).bvarray, dfb(i).bv_scanrate);
    end
end


%% glm
xa = [[dfa.speed]',[dfa.acceleration]',[dfa.duration]',[dfa.maxspeed]',[dfa.distance]',[repmat(group_A_value, length(dfa), 1)]];
ya = [dfa.maxdff]';
xb = [[dfb.speed]',[dfb.acceleration]',[dfb.duration]',[dfb.maxspeed]',[dfb.distance]',[repmat(group_B_value, length(dfb), 1)]];
yb = [dfb.maxdff]';
x = cat(1,xa,xb);
y = cat(1,ya,yb);
%b = glmfit(x,y);

tb = array2table(cat(2,x,y), 'VariableNames',{'speed','acceleration','duration','maxspeed','distance','group','maxdff'});

bb = fitglm(tb);
disp(bb);
% Included trials:
%disp(filelistpath);
%sprintf('Total bouts: %d', length(df))

%% Plot time course.
mxa = reshape([dfa.bvarray], [], length(dfa));
mxa = mxa';
meantla = mean(mxa,1);
stdtla = std(mxa,1);
stetla = stdtla/sqrt(length(dfa));
plot(mxa');

mxb = reshape([dfb.bvarray], [], length(dfb)); 
mxb = mxb';
meantlb = mean(mxb,1);
stdtlb = std(mxb,1);
stetlb = stdtlb/sqrt(length(dfb));
plot(mxb');

errorbar(1:length(meantla),meantla*100,stetla*100);
hold on
errorbar(1:length(meantlb),meantlb*100,stetlb*100);
hold off
legend({group_A_name, group_B_name});
ytickformat('percentage');
xticks([1:length(meantla)]);
xticklabels([1:length(meantla)] - 4);
xlabel('Timecourse (sec)');
ylabel('dff changes');

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
