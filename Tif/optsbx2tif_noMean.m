function output = optsbx2tif_noMean(animalID, dateID, run, pmt, side, layers, outputTif)

    % default is just read green channel
    if nargin<4, pmt = 0; end
    
    % side = 0 is topview;
    % side = 1 is to build 3D model
    % side = 2 is sideview lateral to middle
    if nargin<5, side = 0; end
    
    % layers is a 2 0-1 number vector. It define which depth need to build
    % tif. For example [0.5, 1] mean from half to top.
    if nargin<6, layers = [0,1]; end
    
    if nargin<7, outputTif = 1; end

    path = sbxPath(animalID, dateID, run, 'sbx'); 
    
    inf = sbxInfo(path, true);

    if ~isfield(inf, 'volscan') || length(inf.otwave)<2, error('This function is only used for read whole opto frames.'); end

    % Set in to read the whole file if unset
    nf = inf.max_idx + 1; 

    nr = inf.sz(1);
    nc = inf.sz(2);
    
    % ---------------------------------------
    x = fread(inf.fid, inf.nsamples/2*nf, 'uint16=>uint16');
    x = reshape(x, [inf.nchan inf.sz(2) inf.recordsPerBuffer nf]);
    x = intmax('uint16') - permute(x, [1 3 2 4]);
    x = squeeze(x(pmt+1, :, :,:));
   
    
   
    y = x(10:end-10, 76:end-60, :);
    
    depth = floor(length(inf.otwave)*layers);
    if depth(1) == 0, depth(1) = 1; end

    for j = 1:nf

        tmp = binxy(y(:, :, j), 2);

        tmp = uint8(tmp/255);

        if pmt == 0
            fnm = 'greenChl'; 
        else
            fnm = 'redChl';
        end

        imwrite(tmp, [path(1:end-4), '_', fnm, '.tif'], ...
            'WriteMode', 'append');

        wd = [num2str(j), ' of ', num2str(nf), ' is done.'];
        disp(wd);
    end
        
    
end