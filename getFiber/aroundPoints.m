function aps = aroundPoints(x, y, distance)
    
    aps = [];
    for i = x-distance:x+distance
        aps = [aps; i, y-distance; i, y+distance];
    end
    
    for i = y-distance+1:y+distance-1
        aps = [aps; x-distance, i; x+distance, i];
    end
    
end