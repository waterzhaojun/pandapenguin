function [output, fftIndReg] = dft_savemethod_partreg2(x, ref, upscale)

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
[tmp,smallidx] = min(output(:,4));
output = output(smallidx,:);

fftIndReg = fftIndReg(:,:,smallidx);

shiftmx = zeros(size(mx));
Nr = ifftshift( -fix(r/2):ceil(r/2)-1 ); % adapted from dftregistration
Nc = ifftshift( -fix(c/2):ceil(c/2)-1 ); % adapted from dftregistration
[Nc,Nr] = meshgrid(Nc,Nr); % adapted from dftregistration
% Register one color, then apply that registration to the other color
for z = 1:f
    tmpFT = fft2( mx(:,:,1,z) );
    fftDepReg = tmpFT.*exp(1i*2*pi*(-shift(z,2)*Nr/r-shift(z,1)*Nc/c)); % adapted from dftregistration
    fftDepReg = fftDepReg*exp(1i*shift(z,5)); % adapted from dftregistration
    shiftmx(:,:,1,z) = abs( ifft2(fftDepReg) );
end


end
