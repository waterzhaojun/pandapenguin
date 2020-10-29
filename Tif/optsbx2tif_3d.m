function output = optsbx2tif_3d(animalID, dateID, run, pmt, layers)

    % default is just read green channel
    if nargin<4, pmt = 0; end
        
    % layers is a 2 0-1 number vector. It define which depth need to build
    % tif. For example [0.5, 1] mean from half to top.
    if nargin<5, layers = [0,1]; end

    path = sbxPath(animalID, dateID, run, 'sbx'); 
    
    inf = sbxInfo(path, true);

    if ~isfield(inf, 'volscan') || length(inf.otwave)<2, error('This function is only used for read whole opto frames.'); end
    
    if inf.nchan == 1, pmt = 0;end

    % Set in to read the whole file if unset
    N = inf.max_idx + 1; 

    nr = inf.sz(1);
    nc = inf.sz(2);
    
    nf = length(inf.otwave);
    
    % ---------------------------------------
    x = fread(inf.fid, inf.nsamples/2*N, 'uint16=>uint16');
    x = reshape(x, [inf.nchan inf.sz(2) inf.recordsPerBuffer N]);
    
    startidx = inf.otparam(3)+1; % only cancle one round
    endidx = N-rem(N,inf.otparam(3));
    
    x = x(:,:,:,startidx:endidx);
    
    %edges = sbxRemoveEdges(path);
    
    outputPath = [path(1:end-4), '_3Dstructure.tif'];
    if exist(outputPath, 'file') == 2, delete(outputPath); end
    
    output = zeros(nr,nc,length(pmt),inf.otparam(3));
    for j = 1:inf.otparam(3)
        %tmpOutputPiece = uint8(zeros(nr, nc, length(pmt))); %now I blocked shrink the pic. If want to shrink, add n here and below
        for i = 1:length(pmt)
            tmpstackframes = ([1:floor(size(x,4)/inf.otparam(3))]-1)*inf.otparam(3)+j;
            tmp = mean(squeeze(x(pmt(i)+1,:,:,tmpstackframes)), 3);
            % tmp = arrayShrink(tmp,2);

            tmp = 65535-permute(tmp, [2,1]);
            %tmp = uint8(tmp/255);
            output(:,:,i,j)=tmp;
        end

%         imwrite(tmp, outputPath, ...
%             'WriteMode', 'append');
% 
        wd = [num2str(j), ' of ', num2str(nf), ' is done.'];
        disp(wd);
    end
    output = uint16(output);
    mx2tif(output, outputPath);

end