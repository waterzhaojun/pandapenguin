function mx2tif_v1(mx, path)
% cChannel = 0: grey; 1: red; 2: green; 3: blue;
% transfer a 3D matrix to tif
    mxclass = class(mx);
    

    [r,c,ch,f] = size(mx);
    ch = 1;
    mx = reshape(mx, [r,c,ch,f]);




    if exist(path, 'file') == 2, delete(path); end

    % the follow part may rewrite to a shorter version.
    for i = 1:f

        tmp = 65535-permute(squeeze(mx(1,:,:,i)), [2,1]);
        
        
        tmp = feval(mxclass, tmp);
        imwrite(tmp, path, 'WriteMode', 'append');
        
        if rem(i, 100) == 0
            wd = [num2str(i), ' of ', num2str(f), ' is done.'];
            disp(wd);   
        end
    end
end