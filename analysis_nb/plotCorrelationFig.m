function plotCorrelationFig(results,keys,titles,groups, savepath,varargin)
parser = inputParser;
addRequired(parser, 'results');
addRequired(parser, 'keys');
addRequired(parser, 'titles'); 
addRequired(parser, 'groups'); 
addOptional(parser, 'savepath', '', @ischar);
parse(parser, results, keys, titles, groups, savepath, varargin{:});
savepath = parser.Results.savepath;
f1 = fitlm(getStructField(results{1}.bout, keys{1}), getStructField(results{1}.bout, keys{2}));
f2 = fitlm(getStructField(results{2}.bout, keys{1}), getStructField(results{2}.bout, keys{2}));
figure;
hold on
h1 = plot(f1);
h2 = plot(f2);
legend([h1(1),h2(1)], {groups{1}, groups{2}});
set(h1,'color','red');
set(h2,'color','blue');
title(['correlation between ', titles{1}, ' and ', titles{2}]);
xlabel(titles{1});
ylabel(titles{2});
hold off
if ~strcmp(savepath, '')
    disp('save');
    saveas(gcf,savepath);
end
end