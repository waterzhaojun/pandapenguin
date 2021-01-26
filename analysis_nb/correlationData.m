function df = correlationData(structs, varargin)

% This function is to build a correlation struct df from two struct dfs.
% To avoid the conflict of the field names, set {'df1', 'df2'} to append
% the field name with a specific title.

parser = inputParser;
addRequired(parser, 'structs' );
addOptional(parser, 'heads', {});
parse(parser,structs, varargin{:});

heads = parser.Results.heads;
if length(heads) == 0
    heads = repmat({''}, 1, length(structs));
end
if length(heads) ~= length(structs)
    error('not equal number of structs and heads');
end


for i = 1:length(structs)
    structs{i} = cell2struct(struct2cell(structs{i}), append(heads{i}, fieldnames(structs{i})));
end

df= structs{1};
for i = 2:length(structs)
    df = mergeTwoDf(df, structs{i});
end

end

function df = mergeTwoDf(mainStruct, corrStruct)

mergeStructs = @(x,y) cell2struct([struct2cell(x);struct2cell(y)], [fieldnames(x);fieldnames(y)]);
    
idx = 1;
for i = 1:length(mainStruct)
    bout = mainStruct(i);
    for j = 1:length(corrStruct)
        roi = corrStruct(j);
        tmp = mergeStructs(bout, roi);
        if idx == 1
            df = tmp;
        else
            df = [df;tmp];
        end
        idx = idx + 1;
    end
end

end