function mx2tif(mx, path, bint)
    
% transfer a 3D matrix to tif
    if nargin <3, bint = 1; end
    
    if ndims(mx) ~= 3
        error('only support 3 dimension matrix');
    end
    
    [r,c,f] = size(mx);
    nf = floor(size(mx, 3)/bint);
    overf = f - nf*bint;
    mxclass = class(mx);
    
    if bint > 1
        mx = mx(:,:,1:end-overf);
        mx = reshape(mx, [r,c,bint, nf]);
        mx = squeeze(mean(mx, 3));
    end
    
    if strcmp(mxclass, 'uint16')
        mx = uint8(mx/255);
    elseif strcmp(mxclass, 'double')
        tmax = max(mx, [], 'all');
        mx = uint8(mx/tmax*255);
    end
    
   
    
    if exist(path, 'file') == 2, delete(path); end

    for i = 1:nf
        tmp = mx(:,:,i);
        imwrite(tmp, path, 'WriteMode', 'append');
        
        if rem(1, 100) == 0
            wd = [num2str(i), ' of ', num2str(nf), ' is done.'];
            disp(wd);   
        end
    end
end