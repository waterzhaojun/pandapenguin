function result = get_bout(array, scanrate, varargin)
parser = inputParser;
addRequired(parser, 'array', @isnumber );
addRequired(parser, 'scanrate', 15, @(x) isnumeric(x) && isscalar(x) && (x>0));
addParameter(parser, 'gap', 2, @(x) isnumeric(x) && isscalar(x) && (x>0)); % how many seconds of gap to be considered as the end of the bout.
addParameter(parser, 'duration', 2, @(x) isnumeric(x) && isscalar(x) && (x>0)); % how many seconds at least to be considered as a bout.
addParameter(parser, 'threshold', 1, @(x) isnumeric(x) && isscalar(x) && (x>0)); % The threshold of blocks ran in one sec to be considered as running.

parse(parser,array, scanrate, varargin{:});

recordlength = floor(length(array) / parser.Results.scanrate) * parser.Results.scanrate;
bintarray = reshape(array(1:recordlength), parser.Results.scanrate, []);
bintarray = sum(bintarray, 1);
bintarray = (abs(bintarray) > 0);
bintarray = fillLogicHole(bintarray, parser.Results.gap);
result=struct();
boutstart = 1;
flag = 0;
array1 = [0, bintarray, 0];
for i = 2:length(array1)
    if prod(array1(i-1:i) == [0 1]) && ~flag
        result.bout{boutstart}.startsec = i-1;
        flag = 1;
    elseif prod(array1(i-1:i) == [1 0]) && flag
        result.bout{boutstart}.endsec = i-1;
        flag = 0;
        boutstart = boutstart+1;
    end
end

for i = 1:length(result.bout)
    result.bout{i}.


end