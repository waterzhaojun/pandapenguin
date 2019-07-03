function value = cross_value(vector,i)

    upperpart = mean(vector(i:end));
    lowerpart = mean(vector(1:i));
    
    value = upperpart - lowerpart;

end