function result2csv(path,varargin)

parser = inputParser;
addRequired(parser, 'path', @ischar );
addOptional(parser, 'excludeFields', {});
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