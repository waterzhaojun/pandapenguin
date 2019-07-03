function prepare3Dtif(animalID, dateID, run, fileType)
    
    if nargin < 4, fileType = 'sbx'; end
    if nargin < 3, error('need run'); end
    
    path = sbxPath(animalID, dateID, run, fileType); % Gets the path to the sbx file of mouse, date, run

    % red pmt
    inf = sbxInfo(path, true);

    if ~isfield(inf, 'volscan') || length(inf.otwave)<2, error('This function is only used for read whole opto frames.'); end

    % Set to start at beginning if necessary
    k = 0; 
    % Set in to read the whole file if unset
    N = inf.max_idx + 1; 
    
    nr = inf.sz(1);
    nc = inf.sz(2);
    nf = length(inf.otwave);
    output = zeros(nr, nc, nf, 3);
    
    x = fread(inf.fid, inf.nsamples/2*N, 'uint16=>uint16');
    x = reshape(x, [inf.nchan inf.sz(2) inf.recordsPerBuffer N]);
    x = intmax('uint16') - permute(x, [1 3 2 4]);

    if inf.config.pmt0_gain >0
        pmt = 1; % green channel
        y = squeeze(x(pmt, :, :, :));
        for i = 1:length(inf.otwave)
            tmpstackframes = ([1:floor(size(y,3)/length(inf.otwave))]-1)*length(inf.otwave)+i;
            output(:,:,i, 2) = mean(y(:,:,tmpstackframes), 3);
        end
    end

    if inf.config.pmt1_gain >0
        pmt = 2; % red channel
        y = squeeze(x(pmt, :, :, :));
        for i = 1:length(inf.otwave)
            tmpstackframes = ([1:floor(size(y,3)/length(inf.otwave))]-1)*length(inf.otwave)+i;
            output(:,:,i, 1) = mean(y(:,:,tmpstackframes), 3);
        end
    end

    output = uint8(output/255);
    
    output = output(:, 76:720, :, :);

    writetiff(output, [path(1:end-4),'_3D.tif']); %, 
    
end