function maxMatrix = getMaxMatrix(array)

    if ndims(array) ~= 3
        sprinf('need a 3-D array');
        return;
    end
    
    [nr, nc, nf] = size(array);
    
    maxMatrix = uint16(zeros(nr, nc));
        
    for iFrame = 1:nf
        tmp = uint16(array(:,:,iFrame));
        maxMatrix(1:end) = max(maxMatrix(1:end), tmp(1:end));
    end
    
end

