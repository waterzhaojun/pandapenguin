function newmx = downsamplef(mx, bintsize)

if bintsize > 1
    f = size(mx,4);
    idx = [0:f] * bintsize +1;
    idx = idx(idx <= f);
    newmx = mx(:,:,:,idx);
elseif bintsize == 1
    newmx = mx;
else
    error('bintsize need to greater or equal to 1');
end


end