function output = downsample(mx,parameters, varargin)
    disp('start downsample matrix');
    
    oritype = class(mx);
    
    bint = parameters.config.downsample_size;
    
    output = mx;
    
    nd = ndims(output);
    if nd == 3
        [r,c,f] = size(output);
        output = reshape(output, [r,c,1,f]);
    end
    
    [r,c,ch,f] = size(output);
    
    if bint ~= 1
        nr = floor(r/bint)*bint;
        nc = floor(c/bint)*bint;

        output = output(1:nr, 1:nc, :, :);
        % size(output)
        output = reshape(mean(reshape(output, [bint, nr/bint, nc, ch, f]), 1), [nr/bint, nc, ch, f]);
        output = reshape(mean(reshape(output, [nr/bint, bint, nc/bint, ch, f]), 2), [nr/bint, nc/bint, ch, f]);
    end
    
    [r,c,ch,f] = size(output);
    
    % considering csd, not sure 0.1 is a good cut.
    flag_shift = find(strcmp(varargin, 'shift'));
    if flag_shift
        % onlye registrated channel need to skip bad shifted frmaes.
        regch = parameters.config.registratePmt + 1;
        if ch == 1
            regch = 1;
        end
        shift = varargin{flag_shift + 1};
        overshiftlist = find(abs(shift(:,1)) > (0.1 * c * parameters.config.downsample_size) | abs(shift(:,2)) > (0.1 * r * parameters.config.downsample_size));
        % disp(['need to pass frame: ', overshiftlist]);
        output(:,:,regch, overshiftlist) = nan;
    end
    
    
    if parameters.config.output_fq
        tbint = parameters.downsample_t;
        nf = floor(f/tbint)*tbint;
        output = output(:, :, :, 1:nf);
        output = nanmean(reshape(output, [r, c, ch, tbint, nf/tbint]), 4);
        output = reshape(output, [r,c,ch,nf/tbint]);
    end
    
    if nd == 3
        output = squeeze(output);
    end
    
    output = feval(oritype, output);

end