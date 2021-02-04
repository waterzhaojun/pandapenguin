function plot_correlation(df, x_column_name,y_column_name,varargin)
parser = inputParser;
addRequired(parser, 'df' );
addRequired(parser, 'x_column_name');
addRequired(parser, 'y_column_name');
addOptional(parser, 'group_column_name', []);
parse(parser,df, x_column_name, y_column_name, varargin{:});

x = [df.(x_column_name)];
y = [df.(y_column_name)]; 

t = table(x',y');
t.Properties.VariableNames = {x_column_name, y_column_name}

f = fitlm(t,[x_column_name ' ~ ', y_column_name]);
plot(f)

% scatter(x,y);
% xlabel(x_column_name);
% ylabel(y_column_name);

end