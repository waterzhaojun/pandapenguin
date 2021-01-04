function array = getStructField(result, key)
% This function is to extract an array from result with field key.

array = [];
for i = 1:length(result)
    tmp = result{i};
    array = [array, tmp.(key)];
    
end


end