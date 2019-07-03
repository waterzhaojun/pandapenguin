function colorTifStack(tifPath, rgb)
    % this function is to color the gray tif by give rgb 1/2/3.
    
    tif = loadTifStack(tifPath);
    nf = length(tif);
    [nr, nc] = size(tif{1});
    
    out = zeros(nr, nc, 3);
        
    maxV = max(max([tif{:}]));
        
    for i = 1:nf
        out(:,:,rgb) = tif{i}(:,:)/maxV;
        imwrite(out(:,:,:), [tifPath(1:end-4), '_color.tif'], 'WriteMode', 'append');
    end

end