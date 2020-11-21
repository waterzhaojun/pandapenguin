function [result, array_sec] = get_bout(array, scanrate, varargin)
parser = inputParser;
addRequired(parser, 'array', @isnumeric ); % This array must be deshaked.
addRequired(parser, 'scanrate', @(x) isnumeric(x) && isscalar(x) && (x>0));
addParameter(parser, 'gap', 2, @(x) isnumeric(x) && isscalar(x) && (x>0)); % how many seconds of gap to be considered as the end of the bout.
addParameter(parser, 'duration', 2, @(x) isnumeric(x) && isscalar(x) && (x>0)); % how many seconds at least to be considered as a bout.
addParameter(parser, 'threshold', 1, @(x) isnumeric(x) && isscalar(x) && (x>0)); % The threshold of blocks ran in one sec to be considered as running.

parse(parser,array, scanrate, varargin{:});

recordlength = floor(length(array) / parser.Results.scanrate) * parser.Results.scanrate;
array_sec = reshape(abs(array(1:recordlength)), parser.Results.scanrate, []);
array_sec = sum(array_sec, 1);
bintarray = (array_sec >= parser.Results.threshold) *1;
bintarray = fillLogicHole(bintarray, parser.Results.gap);
bintarray = fillLogicHole(bintarray, parser.Results.duration, 'reverse',1);
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
    startidx = (result.bout{i}.startsec - 1) * parser.Results.scanrate +1;
    endidx = result.bout{i}.endsec * parser.Results.scanrate;
    tmparray = array(startidx:endidx);
    tmpidx = find(abs(tmparray) > 0);  % Not sure if 0 is good here. Need to edit based on threshold later.
    result.bout{i}.startidx = startidx + min(tmpidx) - 1;
    result.bout{i}.endidx = startidx + max(tmpidx) - 1;
    result.bout{i}.array = array(result.bout{i}.startidx:result.bout{i}.endidx);
    result.bout{i}.distance = sum(abs(result.bout{i}.array));
    result.bout{i}.duration = length(result.bout{i}.array);
    result.bout{i}.speed = result.bout{i}.distance * parser.Results.scanrate / result.bout{i}.duration;
    tmp = sum(result.bout{i}.array);
    if tmp <= 0
        result.bout{i}.direction = -1;
    else
        result.bout{i}.direction = 1;
    end
    result.bout{i}.maxspeed = max(abs(result.bout{i}.array)) * parser.Results.scanrate / result.bout{i}.duration;
end

end