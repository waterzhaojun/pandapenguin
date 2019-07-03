function f = meltWithGoodFrame(array, goodFrame, bin)

    %if nargin < 2, out = data; return; end
    %if bin < 2, out = data; return; end

    [y, x, t] = size(array);
    frames = floor(t/bin);
    f = uint16(zeros(y, x, frames));
    currentFrame = 0;
    for i = 1:frames
        framesOfPeriod = goodFrame(goodFrame>=((i-1)*bin+1) & goodFrame<=i*bin);
        if length(framesOfPeriod) > 0
            currentFrame = currentFrame +1;
            f(:,:,currentFrame) = uint16(mean(array(:,:,framesOfPeriod), 3));
        end
    end
    f = f(:,:,1:currentFrame);
    
end