function result = bintf(mx, binsize)
    % shrink the 4th dimension of the mx, which is f.

    [r,c,ch,f] = size(mx);
    
    nf = floor(f/binsize)*binsize;
    newf = nf/binsize;
    
    mx = mx(:,:,:,1:nf);
    result = reshape(mx, [r, c, ch, binsize, newf]);
    result = squeeze(mean(result,4));
    result = reshape(result, r,c,ch,newf);
    
end