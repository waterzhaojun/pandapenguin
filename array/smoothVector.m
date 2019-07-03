function output = smoothVector(vec, bin)
    
    width = ceil(bin/2);
    output = [];
    for(i = 1:length(vec))
        if(i<width)
            output = [output, mean(vec(1:i+width-1))];
        elseif((length(vec)-i)<width)
            output = [output, mean(vec(i-width+1:length(vec)))];
        else
            output = [output, mean(vec(i-width+1:i+width-1))];
        end
        
        
    end



end