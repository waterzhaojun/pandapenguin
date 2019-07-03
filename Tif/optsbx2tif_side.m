function output = optsbx2tif_side(animalID, dateID, run, pmt, layers, outputTif)

    % default is just read green channel
    if nargin<4, pmt = 0; end
    
    % layers is a 2 0-1 number vector. It define which depth need to build
    % tif. For example [0.5, 1] mean from half to top.
    if nargin<5, layers = [0,1]; end
    
    if nargin<6, outputTif = 1; end

    path = sbxPath(animalID, dateID, run, 'sbx'); 
    
    inf = sbxInfo(path, true);

    if ~isfield(inf, 'volscan') || length(inf.otwave)<2, error('This function is only used for read whole opto frames.'); end

    % Set in to read the whole file if unset
    N = inf.max_idx + 1; 

    nr = inf.sz(1);
    nc = inf.sz(2);
    nf = floor(N/length(inf.otwave));

    % ---------------------------------------
    x = fread(inf.fid, inf.nsamples/2*N, 'uint16=>uint16');
    x = reshape(x, [inf.nchan inf.sz(2) inf.recordsPerBuffer N]);
    
    %x = squeeze(x(pmt+1, :, :,:));
    %x = intmax('uint16') - permute(x, [1 3 2 4]);
    
    edges = sbxRemoveEdges(path);
    
    % ------------------------------------------
    depth = floor(length(inf.otwave)*layers);
    if depth(1) == 0, depth(1) = 1; end
    
    if pmt == 0
            fnm = 'greenChl_sideView'; 
        else
            fnm = 'redChl_sideView';
    end
    
    outputPath = [path(1:end-4), '_', fnm, '.tif'];
    if exist(outputPath, 'file') == 2, delete(outputPath); end

    for j = 0:(nf-1)
        
        tmp = squeeze(x(pmt+1, edges(1)+1:end-edges(2), edges(3)+1:end-edges(4), j*length(inf.otwave)+depth(1):j*length(inf.otwave)+depth(2)));
        %tmp = max(squeeze(x(pmt+1, :, :, j*length(inf.otwave)+depth(1):j*length(inf.otwave)+depth(2))), [],3);
        %tmp = tmp(edges(1)+1:end-edges(2), edges(3)+1:end-edges(4));
        
        tmp = 65535-permute(tmp, [3,1,2]);
        %tmp = binxy(tmp, 2);
        tmp = mean(tmp, 3);
        tmp = uint8(tmp/255);

        imwrite(tmp, outputPath, ...
            'WriteMode', 'append');

        wd = [num2str(j+1), ' of ', num2str(nf), ' is done.'];
        disp(wd);
    end
end