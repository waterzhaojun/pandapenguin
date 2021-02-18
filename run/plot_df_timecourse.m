function plot_df_timecourse(df, columnName, varargin)

% Based on the df data, we gonna have 
parser = inputParser;
addRequired(parser, 'df');
addRequired(parser, 'columnName', @ischar);
addOptional(parser, 'type', 'individual', @ischar); % another option is 'avg'parse(parser,path, varargin{:});

parse(parser,df,columnName,varargin{:});
plottype = parser.Results.type;

n = length(df);
mx = reshape([df.(columnName)], [], n);
if strcmp(plottype, 'individual')
    plot(mx);
elseif strcmp(plottype, 'avg')
    avg = mean(mx, 2);
    size(avg);
    sterr = std(mx, 0, 2)/sqrt(n);
    errorbar(avg,sterr);
end


end