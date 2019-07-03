function ny = isClose(v1, v2)
    % v1 should be a single 2 elements vector
    % v2 may be single or multiple 2 elements vectors
    
    ny = 0;
    for i = 1:size(v2,1)
        x = abs(v1(1) - v2(i,1));
        y = abs(v1(2) - v2(i,2));
    
        if (x <= 1 & y <= 1)
            ny = ny+1;
        end
        
    end
    
    if ny > 0
        ny = 1;
    end
    
end