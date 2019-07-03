function output = singlePlateSbx2tif(animalID, dateID, run, pmt, bint, outputTif)

    % default is just read green channel
    if nargin<4, pmt = 0; end
    
    if nargin<5, bint = 1; end
           
    if nargin<6, outputTif = 1; end

    path = sbxPath(animalID, dateID, run, 'sbx'); 
    
    inf = sbxInfo(path, true);

    if ~isfield(inf, 'volscan') && length(inf.otwave)>1, error('This function is only used for single plate sbx frames.'); end

    % Set in to read the whole file if unset
    N = inf.max_idx + 1; 

    nr = inf.sz(1);
    nc = inf.sz(2);
    nf = floor(N/bint);

    % ---------------------------------------
    x = fread(inf.fid, inf.nsamples/2*N, 'uint16=>uint16');
    x = reshape(x, [inf.nchan inf.sz(2) inf.recordsPerBuffer N]);
    
    %x = squeeze(x(pmt+1, :, :,:));
    %x = intmax('uint16') - permute(x, [1 3 2 4]);
    
    edges = sbxRemoveEdges(path);
    
    if pmt == 0
            fnm = 'greenChl'; 
        else
            fnm = 'redChl';
    end
    outputPath = [path(1:end-4), '_', fnm, '.tif'];
    if exist(outputPath, 'file') == 2, delete(outputPath); end
    
    
    for j = 0:(nf-1)

        tmp = mean(squeeze(x(pmt+1, :, :, (j*bint+1):((j+1)*bint))), 3);

        tmp = tmp(edges(1)+1:end-edges(2), edges(3)+1:end-edges(4));
        
        %tmp = binxy(tmp, 2);

        tmp = 65535-permute(tmp, [2,1]);
        tmp = uint8(tmp/255);
       
        imwrite(tmp, outputPath, ...
            'WriteMode', 'append');
        
        if rem(j, 100) == 0
            wd = [num2str(j+1), ' of ', num2str(nf), ' is done.'];
            disp(wd);
        end
    end

end
