function mx = mxFromSbxPath(path)
    % This function is to extract mx from sbx path. It is a replacement of
    % mxFromSbx function.

    
    inf = sbxInfo(path, true);
    % Set in to read the whole file if unset
    N = inf.max_idx + 1; 

    nr = inf.sz(1);
    nc = inf.sz(2);
    nf = N;

    % ---------------------------------------
    x = fread(inf.fid, inf.nsamples/2*N, 'uint16=>uint16');
    
    x = reshape(x, [inf.nchan inf.sz(2) inf.recordsPerBuffer N]);
    x = permute(x, [3,2,1,4]);

    mx = uint16(65535-x);


end