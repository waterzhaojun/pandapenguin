function mx2tif_v2(mx, path, cChannel)
% cChannel = 0: grey; 1: red; 2: green; 3: blue;
% transfer a 3D matrix to tif
    mxclass = class(mx);
    
    if ndims(mx) == 3
        [r,c,f] = size(mx);
        ch = 1;
        mx = reshape(mx, [r,c,ch,f]);
    elseif ndims(mx) == 4
        [r,c,ch,f] = size(mx);
    else
        error('only support 3 or 4 dimension matrix');
    end
    
    
    
    if exist(path, 'file') == 2, delete(path); end

    % the follow part may rewrite to a shorter version.
    for i = 1:f
        tmp = zeros(r,c,3);
        tmp(:,:,1) = mx(:,:,2,i);
        tmp(:,:,2) = mx(:,:,1,i);

        
        tmp = feval(mxclass, tmp);
        imwrite(tmp, path, 'WriteMode', 'append');
        
        if rem(i, 100) == 0
            wd = [num2str(i), ' of ', num2str(min([nf, frames])), ' is done.'];
            disp(wd);   
        end
    end
end