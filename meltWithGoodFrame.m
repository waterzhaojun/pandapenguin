function sig = meltWithGoodFrame(vec, goodFrames, n)
        
    if nargin < 3 || isempty(n), n = 15.5; end
   
    frames = floor(length(vec)/n);
    sig = [];
    for i = 1:frames
        tmp = (goodFrames>=((i-1)*n+1) & goodFrames<=i*n);
        framesOfPeriod = goodFrames(tmp);
        if ~isempty(framesOfPeriod)
            sig = [sig, mean(vec(framesOfPeriod))];
        end
    end
end