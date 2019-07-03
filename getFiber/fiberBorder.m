function aroundxy = fiberBorder(fiberxy, distance)

    if nargin <2, distance = 3; end
    
    aroundxy = fiberBorderCore(fiberxy, distance);
    aroundxy2 = fiberBorderCore(fiberxy, distance-1);
    keepind = [];
    for i = 1:length(aroundxy)
        if length(intersect(aroundxy(i, :), aroundxy2, 'rows')) == 0
            keepind = [keepind, i];
        end
    end
    aroundxy = aroundxy(keepind, :);
    

end