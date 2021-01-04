function result2csv(path,varargin)

parser = inputParser;
addRequired(parser, 'path', @ischar );
addOptional(parser, 'excludeFields', {});
%addParameter(parser, 'output_mov_fbint', 1, @(x) isnumeric(x) && isscalar(x) && (x >= 0));
%addParameter(parser, 'output_response_fig_width', 1000, @(x) isnumeric(x) && isscalar(x) && (x > 0)); % The output is not exactly 1000px, but close to 1000 based on the bint size.
parse(parser,path, varargin{:});

excludeFields = parser.Results.excludeFields;
outputpath = [path(1:end-3), 'csv'];
result = load(path);
result = result.result;

if length(excludeFields) > 0
    for i = 1:length(excludeFields)
        result = rmfield(result, excludeFields(i));
    end
end
    

df = struct2table(result);
writetable(df, outputpath);

end