function idx = turnpoint_1d(array)
% This function is to find the turning point of an 1D array. 

newarray = [];
for i = 3:(length(array)-2)
    tmp = mean(array(1:i)) - mean(array(i:end));
    newarray = [newarray, tmp];
end
[~,idx] = max(newarray);
idx = idx + 2;





end