function [output, fftIndReg] = dft_savemethod2(x, ref, upscale)
% This method do a series of registration by take part of img horizantally
% then compare to get closest shift.
if nargin < 3, upscale = 10; end

[r,c] = size(x);

piece = 10
idx = floor(linspace(1,c,piece));
output = zeros([piece-2,4]);

for i = 2:length(idx)-1
    if i < c/2
        indFT = fft2(x(:,idx(i):end));
        refFT = fft2(ref(:,idx(i):end));
    else
        indFT = fft2(x(:,1:idx(i)));
        refFT = fft2(ref(:,1:idx(i)));
    end

    [output(i-1,:), tmp] = dftregistration( refFT, indFT, upscale );

end
[tmp,smallidx] = min(output(:,1));
output = output(smallidx,:);

Nr = ifftshift( -fix(r/2):ceil(r/2)-1 ); % adapted from dftregistration
Nc = ifftshift( -fix(c/2):ceil(c/2)-1 ); % adapted from dftregistration
[Nc,Nr] = meshgrid(Nc,Nr); % adapted from dftregistration

tmpFT = fft2(x);
fftDepReg = tmpFT.*exp(1i*2*pi*(-output(3)*Nr/r-output(4)*Nc/c)); % adapted from dftregistration
fftIndReg = fftDepReg*exp(1i*output(2)); % adapted from dftregistration
% fftIndReg = abs( ifft2(fftDepReg) );



end
