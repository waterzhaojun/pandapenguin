function mx = dft(mx, ref, parameters)

    if ndims(mx) == 3
        [r,c,f] = size(mx);
        mx = reshape(mx, [r,c,1,f]);
    end
    
    [r,c,ch,f] = size(mx);
    metadata = {};
    metadata.Nframe = f;
    metadata.Ncolor = ch;
    
    if ch == 3
        rawMovie = mx;
        metadata.goodColor = [1,2,3];
    elseif ch == 2
        rawMovie = zeros(r,c,3,f);
        rawMovie(:,:,1:2,:) = mx;
        metadata.goodColor = [1,2];
    elseif ch == 1
        rawMovie = zeros(r,c,3,f);
        rawMovie(:,:,1,:) = mx;
        metadata.goodColor = [1];
    end
    
    
        
        
    

end