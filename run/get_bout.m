function [result, array_sec] = get_bout(array, varargin)
parser = inputParser;
addRequired(parser, 'array', @isnumeric ); % This array must be deshaked.
addOptional(parser, 'scanrate', 15, @(x) isnumeric(x) && isscalar(x) && (x>0));
% addParameter(parser, 'gap', 2, @(x) isnumeric(x) && isscalar(x) && (x>0)); % how many seconds of gap to be considered as the end of the bout.
% addParameter(parser, 'duration', 2, @(x) isnumeric(x) && isscalar(x) && (x>0)); % how many seconds at least to be considered as a bout.
% addParameter(parser, 'threshold', 1, @(x) isnumeric(x) && isscalar(x) && (x>0)); % The threshold of blocks ran in one sec to be considered as running.

parse(parser,array, varargin{:});
srate = parser.Results.scanrate;

config = run_config();
direction_threshold = config.bout_direction_percent_threshold;
duration_threshold = config.bout_duration_threshold;
gap_threshold = config.bout_gap_duration_threshold;
distance_threshold = config.bout_sec_distance_threshold;

% recordlength = floor(length(array) / srate) * srate;
% array_sec = reshape(abs(array(1:recordlength)), srate, []);
% array_sec = sum(array_sec, 1);
array_sec = bint1D(abs(array), srate, 'method', 'sum');
bintarray = (array_sec >= distance_threshold) *1;
bintarray = fillLogicHole(bintarray, gap_threshold);
bintarray = fillLogicHole(bintarray, duration_threshold, 'reverse',1);
result=struct();
result.bout = {};
boutstart = 1;
flag = 0;
array1 = [0, bintarray, 0];
% I didn't let the loop start from 2 as I think the beginning bout need to
% have enough rest time before start.
for i = (gap_threshold+1):length(array1) 
    if prod(array1(i-1:i) == [0 1]) && ~flag
        result.bout{boutstart}.startsec = i-1;
        flag = 1;
    elseif prod(array1(i-1:i) == [1 0]) && flag
        result.bout{boutstart}.endsec = i-1;
        flag = 0;
        boutstart = boutstart+1;
    end
end

% The following part is mainly because I find still some short array are
% defined as bout. So I add this line to exclude them.
tmplist = [];
for i = 1:length(result.bout)
    if result.bout{i}.endsec - result.bout{i}.startsec >=2
        tmplist = [tmplist,i];
    end
end
result.bout = result.bout(tmplist);
% ==================================================

for i = 1:length(result.bout)
    startidx = (result.bout{i}.startsec - 1) * srate +1;
    endidx = min(result.bout{i}.endsec * srate, length(array));
    tmparray = array(startidx:endidx);

    tmpidx = find(abs(tmparray) > 0);  % Not sure if 0 is good here. Need to edit based on threshold later.
    result.bout{i}.startidx = startidx + min(tmpidx) - 1;
    result.bout{i}.endidx = startidx + max(tmpidx) - 1;
    result.bout{i}.array = array(result.bout{i}.startidx:result.bout{i}.endidx);
    result.bout{i}.distance = sum(abs(result.bout{i}.array));
    result.bout{i}.duration = length(result.bout{i}.array)/srate;
    result.bout{i}.speed = result.bout{i}.distance / result.bout{i}.duration;
%     tmp = sum(result.bout{i}.array);
%     if tmp <= 0
%         result.bout{i}.direction = -1;
%     else
%         result.bout{i}.direction = 1;
%     end
    result.bout{i}.direction = identify_running_direction(result.bout{i}.array, direction_threshold);
    result.bout{i}.maxspeed = max(abs(result.bout{i}.array)) * srate / result.bout{i}.duration;

    % The following part is to calculate acceleration based 1hz array. I don't sure if 1hz is better than original rate.
    % Be careful I used absolute value here.
    % The max acceleration is used for this bout's acceleration. The
    % acceleration _delay is how many sec after the start of the bout to
    % get the max acceleration moment.
    tmparraysec = bint1D(abs(tmparray), srate, 'method', 'sum'); 
    tmpacc = diff(tmparraysec);
    [result.bout{i}.acceleration, result.bout{i}.acceleration_delay] = max(tmpacc); 
end

end