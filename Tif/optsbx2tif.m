function optsbx2tif(animalID, dateID, run, varargin)

    % default is just read green channel
    % if only record red channel, also set pmt = 0
    % only treat one channel. If you need both green and red channel, just
    % run it twice.
    % If you only need some layers' data, set layers =a:b. remember scanbox
    % do z stack scanning from bottom to top. usually we don't use top and
    % bottom layer.
    
    p = inputParser;
    validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    addRequired(p, 'animalID', @ischar);
    addRequired(p, 'dateID', @ischar);
    addRequired(p, 'run', validScalarPosNum);
    addOptional(p, 'pmt', 0, @(x) any(validatestring(num2str(x),{'0','1'})));
    addOptional(p, 'layers', 0);
    addParameter(p,'outputType','average', @(x) any(validatestring(x,{'average', 'stack'})));
    
    % This parameter is only usable when we output stack tif.
    addParameter(p,'zbint',1, @(x) isnumeric(x) && isscalar(x) && (x>0)); 
    parse(p,animalID, dateID, run, varargin{:});
    pmt = p.Results.pmt;
    layers = p.Results.layers;
    zbint = p.Results.zbint;
    outputType = p.Results.outputType;
    if pmt == 0
        fnm = 'greenChl'; 
    else
        fnm = 'redChl';
    end

    path = sbxPath(animalID, dateID, run, 'sbx'); 
    
    inf = sbxInfo(path, true);

    %if ~isfield(inf, 'volscan') || length(inf.otwave)<2, error('This function is only used for read whole opto frames.'); end

    % Set frames
    N = inf.max_idx + 1; 
    nf = floor(N/inf.otparam(3));
    
    % set pmt
    if inf.nchan == 1, pmt = 0; end

    % load data, trim, and reshape ---------------------------------------
    x = mxFromSbxPath(path);
    
    edges = sbxRemoveEdges();
    x = x(edges(3)+1:end-edges(4), edges(1)+1:end-edges(2), pmt+1, 1:nf*inf.otparam(3));
    x = reshape(squeeze(x), size(x,1), size(x,2), inf.otparam(3), nf);
    % after this step, x is a matrix with r, c, z, nf.
    
    % set layers, pass the most top and bottom layers.
    if layers == 0, layers = 2:inf.otparam(3)-1; end  
    % layers = 2:inf.otparam(3)-1;
    disp(['make tif from layer ', num2str(layers(1)), ' to layer ', num2str(layers(end))]);
    x = x(:,:,layers, :);
    size(x)
    if strcmp(outputType, 'average')
        x = uint16(reshape(mean(x, 3), size(x,1), size(x,2), 1, []));
    elseif strcmp(outputType, 'stack')
        x = mean(reshape(x, size(x,1), size(x,2), zbint, []), 3);
        x = uint16(x);
    end
    
    % output tif movie.
    outputPath = [path(1:end-4), '_', fnm, '.tif'];
    if exist(outputPath, 'file') == 2, delete(outputPath); end
    mx2tif(x, outputPath);

end