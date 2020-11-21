function result = fillLogicHole(array, gap)
% This function is to fill logic array 0 element to 1 if the length is
% lower or equal to gap.
% The array should be only 0 or 1.
strarray = num2str(array);
for i = 1:gap
    tap = ['1', repmat('  0', 1, i), '  1'];
    newtap = ['1', repmat('  1', 1, i), '  1'];
    strarray = strrep(strarray, tap, newtap);
    % This extra treatment is for 2016a version as when met 1 0 0 1 0 0 1 it
    % will produce 1 1 1 11 1 1 1.
    strarray = strrep(strarray, '11', '1');
end



result = strsplit(strarray, '  ');
result = cellfun(@str2num, result(:));
%result = double(string(result)); % string is only available after 2016b

end