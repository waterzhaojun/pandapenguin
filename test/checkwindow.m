function [turnpoint, newarray] = checkwindow(array)

windowsize = 900;
array = array(2:end) - array(1:end-1);
array = (array > 0) * 1;
f = length(array);
newarray = [];
for i =windowsize+1:f-windowsize
    newarray = [newarray, sum(array(i-windowsize:i)) - sum(array(i:i+windowsize))];

[tmp,turnpoint] = min(newarray);
turnpoint = turnpoint+windowsize;

end
