function direction = identify_running_direction(array, thres)
% This function is to identify the running direction based on the wheel
% running array. The array should be the bout of diff of the original quad file,
% and pretreated by deshake. In this bout it may contain positive and
% negative value. The thres is to set if how many percent of not zero value is
% positive, we will consider it as forward (return 1). For example, thres
% = 50% means if >50% of not zero value is positive, we will consider it is
% running forward.
pos = sum(array>0);
neg = sum(array<0);
totalnozero = pos + neg;
if pos > totalnozero * thres
    direction = 1;
else
    direction = -1;
end

end