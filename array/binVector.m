function output = binVector(vec, bin)
% this function bin the 1D vector with bin parameter

    vecLen = floor(length(vec)/bin);
    output = [];
    for(i=1:vecLen)
        output = [output, mean(vec((i-1)*bin+1:i*bin))];
    end      


end