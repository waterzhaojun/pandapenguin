function [binary_array, res] = get_rest_period(array, length_threshold, kick_ending, scanrate)
% The length_threshold unit is sec
% kick_ending unit is sec. It is a 2 element array, First element is the
% start side kickout second. Second element is the end side kickout second.

% Get all period which running speed is 0.
res = {};
starti = 1;
flag = 0;
for i = 1:length(array)
    if flag == 0 && array(i) == 0
        res(starti).startidx = i;
        flag = 1;
    elseif flag == 1 && array(i) ~= 0
        res(starti).endidx = i-1;
        flag = 0;
        starti = starti + 1;
    end
end

% filter the rest period by length_threshold
keepidx = [];
for i = 1:length(res)
    if res(i).endidx - res(i).startidx >= length_threshold * scanrate
        keepidx = [keepidx, i];
    end
end
res = res(keepidx);

% count the kickout ending, and produce binary_array.
binary_array = zeros(1, length(array));
for i = 1:length(res)
    res(i).startidx = res(i).startidx + kick_ending(1)*scanrate;
    res(i).endidx = res(i).endidx - kick_ending(2)*scanrate;
    binary_array(res(i).startidx:res(i).endidx) = 1;
end


end