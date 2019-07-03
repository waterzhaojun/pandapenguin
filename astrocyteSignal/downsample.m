function output = downsample(mx,bint)
    
    if nargin < 2, bint = 2; end
    
    [r,c,f] = size(mx);
    nr = floor(r/bint)*bint;
    nc = floor(c/bint)*bint;
    
    output = mx(1:nr, 1:nc, :);
    size(output)
    output = squeeze(mean(reshape(output, [bint, nr/bint, nc, f]), 1));
    output = squeeze(mean(reshape(output, [nr/bint, bint, nc/bint, f]), 2));

end