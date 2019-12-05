function dft_savemethod_partreg1(x, ref, upscale)

if nargin < 3, upscale = 10; end

[r,c] = size(x);

line = smooth(squeeze(mean(x,1)) - squeeze(mean(ref,1)));
linep = kmeans(line, 2);
p1 = find(linep == 1);
p2 = find(linep == 2);
[tmp, lowpart] = min([mean(line(p1)), mean(line(p2))]);
[tmp, longpart] = max([length(p1), length(p2)]);

% now I will use longpart part to reg
indFT = fft2(x(:,find(linep == longpart)));
refFT = fft2(ref(:,find(linep == longpart)));

[output, fftIndReg] = dftregistration( refFT, indFT, upscale );
shift = zeros([1,5]);
shift(1,1) = output(4); 
shift(1,2) = output(3); 
shift(1,3) = norm(output(3:4)); 
shift(1,4) = output(1); 
shift(1,5) = output(2);

Nr = ifftshift( -fix(r/2):ceil(r/2)-1 ); % adapted from dftregistration
Nc = ifftshift( -fix(c/2):ceil(c/2)-1 ); % adapted from dftregistration
[Nc,Nr] = meshgrid(Nc,Nr); % adapted from dftregistration

tmpFT = fft2(x);
fftDepReg = tmpFT.*exp(1i*2*pi*(-shift(1,2)*Nr/r-shift(1,1)*Nc/c)); % adapted from dftregistration
fftDepReg = fftDepReg*exp(1i*shift(1,5)); % adapted from dftregistration
regx = abs( ifft2(fftDepReg) );


end
