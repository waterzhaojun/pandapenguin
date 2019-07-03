function output = bint1D(vec, bin)
% this function bin the 1D vector with bin parameter

    vecLen = floor(length(vec)/bin);
    output = reshape(vec(1:(bin*vecLen)), [bin, vecLen]);
    output = mean(output, 1);

end