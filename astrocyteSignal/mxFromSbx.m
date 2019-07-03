function mx = mxFromSbx(animalID, dateID, run, pmt)

    % default is just read green channel
    if nargin<4, pmt = 0; end

    path = sbxPath(animalID, dateID, run, 'sbx'); 
    
    inf = sbxInfo(path, true);

    if ~isfield(inf, 'volscan') && length(inf.otwave)>1, error('This function is only used for single plate sbx frames.'); end

    % Set in to read the whole file if unset
    N = inf.max_idx + 1; 

    nr = inf.sz(1);
    nc = inf.sz(2);
    nf = N;

    % ---------------------------------------
    x = fread(inf.fid, inf.nsamples/2*N, 'uint16=>uint16');
    x = reshape(x, [inf.nchan inf.sz(2) inf.recordsPerBuffer N]);

    x = squeeze(x(pmt+1, :, :, :));
    mx = 65535-permute(x, [2,1,3]);

end