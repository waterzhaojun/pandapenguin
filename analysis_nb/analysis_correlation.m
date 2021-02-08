function coef = analysis_correlation(df, x_column_name,y_column_name,varargin)
parser = inputParser;
addRequired(parser, 'df' );
addRequired(parser, 'x_column_name');
addRequired(parser, 'y_column_name');
addOptional(parser, 'showplot', true);
addOptional(parser, 'group_column_name', []);

parse(parser,df, x_column_name, y_column_name, varargin{:});
showplot = parser.Results.showplot;

x = [df.(x_column_name)];
y = [df.(y_column_name)]; 

t = table(x',y');
t.Properties.VariableNames = {x_column_name, y_column_name};

f = fitlm(t,[y_column_name ' ~ ', x_column_name]);

coef = f.Coefficients;

if showplot
    plot(f);
end

end