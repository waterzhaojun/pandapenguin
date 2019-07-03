function signal_dff = dff(signal, chunk, qv_level)
    
    if nargin < 2, chunk = 900; end     % 1 min
    if nargin < 3, qv_level = 0.3; end
        
    nchunk = floor(size(signal,1)/chunk);
    qv_basic = quantile(signal(1:chunk), qv_level);
    signal_dff = zeros(size(signal,1), 1);
    
    for i = 1:nchunk
        t0 = (i-1)*chunk+1;
        if i ~= nchunk
            t1 = i*chunk;
        else
            t1 = size(signal,1);
        end
        qv = quantile(signal(t0:t1), qv_level);
        signal_dff(t0:t1) = signal(t0:t1)+qv_basic-qv;
    end
 
end