function result2csv(path,varargin)
% This function is to convert result to a csv table.
parser = inputParser;
addRequired(parser, 'path', @ischar );
addOptional(parser, 'excludeFields', {}); % This variable is to define which field you don't want to include in output csv file.
addOptional(parser, 'fieldLayer', {}); % If your wanted table is in subfields, you need to fill subfield name here, like: {'roi'}
parse(parser,path, varargin{:});

excludeFields = parser.Results.excludeFields;
fieldLayer = parser.Results.excludeFields;

outputpath = [path(1:end-3), 'csv'];
result = load(path);
result = result.result;
for i = 1:length(fieldLayer)
    result = result.(fieldLayer(i));
end

if length(excludeFields) > 0
    for i = 1:length(excludeFields)
        result = rmfield(result, excludeFields(i));
    end
end
    

df = struct2table(result);
writetable(df, outputpath);

end