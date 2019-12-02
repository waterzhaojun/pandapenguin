
function startpoint = csd_start_point(array, point)
    
    array = array(2:end)-array(1:end-1);
    idx = kmeans(array, 2);
    a1 = mean(array(idx == 1));
    a2 = mean(array(idx == 2));
    [baseline,idnum] = max([a1, a2]);
    % startpoint = find(array > baseline*1.2);
    starts = find(idx == idnum);
    if strcmp(point, 's')
        startpoint = starts(1);
    elseif strcmp(point, 'e')
        startpoint = starts(end);
    end


end