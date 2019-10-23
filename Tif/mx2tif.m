function mx2tif(mx, path, cChannel, bint, frames)
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
    
    
    if nargin < 3, cChannel = 0; end
            
    if nargin <4, bint = 1; end
    
    nf = floor(f/bint);
    if nargin < 5, frames = nf; end
    
    overf = f - nf*bint;
    
    
    if bint > 1
        mx = mx(:,:,1:end-overf);
        mx = reshape(mx, [r,c,ch, bint, nf]);
        mx = reshape(mean(mx, 4),r,c,ch,[]);
    end
    
    

    
    %if strcmp(mxclass, 'uint16')
    %    mx = uint8(mx/255);
    %elseif strcmp(mxclass, 'double')
    %    tmax = max(mx, [], 'all');
    %    mx = uint8(mx/tmax*255);
    %end
    
    if exist(path, 'file') == 2, delete(path); end

    % the follow part may rewrite to a shorter version.
    for i = 1:min([nf, frames])
        if ch == 1 & cChannel == 0
            tmp = squeeze(mx(:,:,:,i));
        elseif ch == 1 & cChannel ~= 0
            tmp = zeros(r,c,3);
            tmp(:,:,cChannel) = squeeze(mx(:,:,:,i));
        else
            tmp = zeros(r,c,3);
            tmp(:,:,1) = mx(:,:,2,i);
            tmp(:,:,2) = mx(:,:,1,i);
        end
        
        tmp = feval(mxclass, tmp);
        imwrite(tmp, path, 'WriteMode', 'append');
        
        if rem(i, 100) == 0
            wd = [num2str(i), ' of ', num2str(min([nf, frames])), ' is done.'];
            disp(wd);   
        end
    end
end