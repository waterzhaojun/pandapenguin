% This notebook is suppose you already finished saving each trial's
% connected correlation data in a root folder (set as below, Each trial is
% a subfolder, and in the folder should have a corr_data.mat).

% This notebook is to analyze the who data correlation and produce some
% plot in root folder.


root = 'C:\Users\Levylab\jun\test2\'; %<====== Set your root here.

pathlist = dir(root);
keepidx = [];
for i = 1:length(pathlist)
    if ~contains(pathlist(i).name, '.')
        keepidx = [keepidx, i];
    end
end
pathlist = pathlist(keepidx);
pathlist = arrayfun(@(x) [x.folder,'\', x.name, '\', 'corr_data.mat'], pathlist, 'UniformOutput', false);

% anaFields = {'runningboutID','runningduration', 'runningspeed', 'runningdistance', ...
%     'runningmaxspeed', 'runningmaxspeed_delay', 'runningacceleration', 'bv_position',...
%     'bv_tissue','bv_type','bv_diameter_bout_max_response', 'bv_diameter_bout_max_response_delay',...
%     'bv_diameter_bout_average_response'};

yfields = {'bv_diameter_bout_max_response', 'bv_diameter_bout_max_response_delay',...
    'bv_diameter_bout_average_response'};
xfields = {'runningduration', 'runningspeed', 'runningdistance', ...
    'runningmaxspeed', 'runningmaxspeed_delay', 'runningacceleration'};

anaFields = {yfields{:}, xfields{:}, ...
    'runningboutID', 'bv_position', 'bv_tissue','bv_type'};

for i = 1:length(pathlist)
    tmp = load(pathlist{i});
    tmp = tmp.df;
    tmpnames = fieldnames(tmp);
    mask = [];
    for tmpn = 1:length(tmpnames)
        if any(strcmp(anaFields,tmpnames{tmpn}))
            mask = [mask, true];
        else
            mask = [mask, false];
        end
    end
    mask = logical(mask);
    tmp = struct2cell(tmp);
    tmp = cell2struct(tmp(mask, :), tmpnames(mask));
    if i == 1
        df = tmp;
    else
        
        df = [df;tmp];
    end
    
end

for i = 1:length(df)
    if contains(df(i).runningboutID, 'CGRP')
        df(i).group = 'CGRP';
    elseif contains(df(i).runningboutID, 'WT')
        df(i).group = 'WT';
    end
end

% add filter here =========
df = df(strcmp({df.bv_tissue}, 'pia'));
df = df(strcmp({df.bv_type}, 'artery'));
df = df(strcmp({df.bv_position}, 'horizontal'));

% Plot correlation fig for each group
r = 3;
c = 2;%length(yfields) * length(xfields);

groupnames = {'CGRP', 'WT'};
df1 = df(strcmp({df.group}, groupnames{1}));
df2 = df(strcmp({df.group}, groupnames{2}));

plotidx = 1;
pageidx = 1;
for i = 1:length(yfields)
    for j = 1:length(xfields)
        if plotidx == 1
            figure('Position', [10 10 c*600 r*800])
            tiledlayout(r,c)
        end
        nexttile
        analysis_correlation(df1, xfields{j}, yfields{i}, true);
        title(groupnames{1});
        
        nexttile
        analysis_correlation(df2, xfields{j}, yfields{i}, true);
        title(groupnames{2});
        
        if plotidx == r
            exportgraphics(gcf,[root, 'Running BV correlation page ', num2str(pageidx), '.pdf'],'ContentType','vector');
            close;
            pageidx = pageidx + 1;
            plotidx = 1;
        else
            plotidx = plotidx + 1;
        end
    end
end
  