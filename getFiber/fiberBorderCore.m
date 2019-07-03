function borderxy = fiberBorderCore(fiberxy, distance)
    
    borderxy = [];
    for i = 1:length(fiberxy)
        borderxy = [borderxy; aroundPoints(fiberxy(i,1), fiberxy(i,2), distance)];
    end
    
    borderxy = unique(borderxy, 'rows');
    keepind = [];
    for i = 1:length(borderxy)
        if borderxy(i,1)>0 & borderxy(i,2)>0 & length(intersect(borderxy(i, 1:2), fiberxy, 'rows')) == 0
            keepind = [keepind, i];
        end
    end
    
    borderxy = borderxy(keepind,:);

end
