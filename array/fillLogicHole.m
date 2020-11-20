function result = fillLogicHole(array, gap)
% This function is to fill logic array 0 element to 1 if the length is
% lower or equal to gap.
% The array should be only 0 or 1.
strarray = num2str(array);
for i = 1:gap
    tap = ['1', repmat('  0', 1, i), '  1'];
    newtap = ['1', repmat('  1', 1, i), '  1'];
    strarray = strrep(strarray, tap, newtap);
end


result = strsplit(strarray, '  ');
result = double(string(result));

end