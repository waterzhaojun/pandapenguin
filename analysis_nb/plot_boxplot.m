function plot_boxplot(array1, array2, groupname, varargin)

% This function is to plot a box plot for two groups with scatter dots.

parser = inputParser;
addRequired(parser, 'array1', @isnumeric ); % running bout signal array
addRequired(parser, 'array2', @isnumeric ); % response signal array
addRequired(parser, 'groupname');
addParameter(parser, 'title', ''); % the HRF model length. Unit is sec
addParameter(parser, 'ylabel', ''); % truncate the beginning several seconds.

parse(parser,array1, array2, groupname, varargin{:});

plot_title = parser.Results.title;
plot_ylabel = parser.Results.ylabel;

boxplot([array1, array2], [ones(length(array1),1); ones(length(array2),1)*2]);
hold on
scatter([ones(length(array1),1).*(1+(rand(length(array1),1)-0.5)/10); ones(length(array2),1).*(2+(rand(length(array2),1)-0.5)/10)],...
    [array1,array2], 'filled');
hold off
xlim([0,3]);
xticks([1,2]);
xticklabels({sprintf('%s (n=%d)', groupname{1}, length(array1)), ...
    sprintf('%s (n=%d)', groupname{2}, length(array2))});
p = ranksum(array1, array2);
xlabel(['p = ', num2str(p)]);
if ~strcmp(plot_title, '')
    title(plot_title);
end

if ~strcmp(plot_ylabel, '')
    ylabel(plot_ylabel);
end



end