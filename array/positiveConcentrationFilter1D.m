function newarray = positiveConcentrationFilter1D(array, window_size, standard)
% This function is to use a slide window across the array. For each
% timepoint, calculate in a range the sum above a threshold or not.
% The input array should be a logic or 0/1 array.

arm = ceil((window_size-1)/2);

if length(array) < window_size, error('The array is not long enough'); end

newarray = zeros(1, length(array));

for i = 1:length(array)
    startidx = i-arm;
    endidx = i+arm;
    
    if startidx < 1
        startidx = 1;
        endidx = startidx +2*arm;
    end
    
    if endidx > length(array)
        endidx = length(array);
        startidx = endidx - 2*arm;
    end
    tmp = array(startidx:endidx);
    tmp = sum(tmp)/(endidx-startidx+1);
    if tmp>standard
        newarray(i) = 1;
    end

end