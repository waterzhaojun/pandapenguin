function output = downsample(mx,parameters)
    disp('start downsample matrix');
    
    oritype = class(mx);
    
    bint = parameters.config.downsample_size;
    
    output = mx;
    
    nd = ndims(output);
    if nd == 3
        [r,c,f] = size(output);
        output = reshape(output, [r,c,1,f]);
    end
    
    if bint ~= 1
        [r,c,ch,f] = size(output);
        nr = floor(r/bint)*bint;
        nc = floor(c/bint)*bint;

        output = output(1:nr, 1:nc, :, :);
        % size(output)
        output = reshape(mean(reshape(output, [bint, nr/bint, nc, ch, f]), 1), [nr/bint, nc, ch, f]);
        output = reshape(mean(reshape(output, [nr/bint, bint, nc/bint, ch, f]), 2), [nr/bint, nc/bint, ch, f]);
    end
    
    if parameters.config.output_fq
        [r,c,ch,f] = size(output);
        tbint = parameters.downsample_t;
        nf = floor(f/tbint)*tbint;
        output = output(:, :, :, 1:nf);
        output = mean(reshape(output, [r, c, ch, tbint, nf/tbint]), 4);
        output = reshape(output, [r,c,ch,nf/tbint]);
    end
    
    if nd == 3
        output = squeeze(output);
    end
    
    output = feval(oritype, output);
    

end