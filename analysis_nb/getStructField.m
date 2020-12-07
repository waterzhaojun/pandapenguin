function array = getStructField(result, key)
array = [];
for i = 1:length(result)
    tmp = result{i};
    array = [array, tmp.(key)];
    
end


end