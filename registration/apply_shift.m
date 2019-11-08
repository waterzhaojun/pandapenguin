function shiftmx = apply_shift(mx, shift)
% mx and shift should have the same length.
[r,c,ch,f] = size(mx);
if ch ~= 1
    error('mx ch should be 1');
end

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

