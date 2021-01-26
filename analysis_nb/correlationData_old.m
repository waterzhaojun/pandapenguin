function df = correlationData_old(mainStruct, corrStruct, varargin)

% deprecate

% This function is to build a correlation struct df from two struct dfs.
% The mainStruct is suppose to running df as this df is the source of the
% stimulation, but we may use other similar df in the future. 
% Each row of the mainStruct is an event. In this event it should have a
% startidx which is when this event happened. Around this startidx, we
% should have a baselineIdx array which is the period considered as baseline.
% Also should have a responseIdx array which is the response period. If
% want to be used as mainStruct, these fields are necessary.
% The corrStruct is a struct. If you have more than one struct df need to
% be correlated, just run this function multiple times. 
% corrStructArray is the field which will be used to extract array data
% from corrStruct df.
% mainStructExcludeFields and corrStructExcludeFields are the fields need
% to be excluded from related struct.

parser = inputParser;
addRequired(parser, 'mainStruct' );
addRequired(parser, 'corrStruct');
addOptional(parser, 'corrStructArray', {'diameter'});
addParameter(parser, 'mainStructExcludeFields', {});
addParameter(parser, 'corrStructExcludeFields', {});
addParameter(parser, 'groupNameHead', {'', ''});
parse(parser,mainStruct, corrStruct, varargin{:});

groupNameHead = parser.Results.groupNameHead;
mainStructExcludeFields = append(groupNameHead{1}, parser.Results.mainStructExcludeFields);
corrStructExcludeFields = append(groupNameHead{2}, parser.Results.corrStructExcludeFields);

excludeFields = {mainStructExcludeFields{:},corrStructExcludeFields{:}};
disp(excludeFields)

mergeStructs = @(x,y,z) cell2struct([struct2cell(x);struct2cell(y)],...
    [append(z{1}, fieldnames(x));append(z{2}, fieldnames(y))]);

idx = 1;
for i = 1:length(mainStruct)
    bout = mainStruct(i);
    for j = 1:length(corrStruct)
        roi = corrStruct(j);
        tmp = mergeStructs(bout, roi, groupNameHead);
        if idx == 1
            df = tmp;
        else
            df = [df;tmp];
        end
        idx = idx + 1;
    end
end

df = rmfield(df, excludeFields);

end