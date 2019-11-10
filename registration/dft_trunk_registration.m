function [regMx, shift, ref]=dft_trunk_registration(mx, upscale)

[r,c,ch,f] = size(mx);    
if ch ~= 1
    error('only support 1 channel registration');
end

refFT = fft2(squeeze(mean(mx, 4))); % this is temp ref
shift = nan(f, 5);
regMx = zeros(r,c,1,f);

for z = 1:f
    indFT = fft2( mx(:,:,1,z) );
    [output, fftIndReg] = dftregistration( refFT, indFT, upscale );
    shift(z,1) = output(4); 
    shift(z,2) = output(3); 
    shift(z,3) = norm(output(3:4)); 
    shift(z,4) = output(1); 
    shift(z,5) = output(2);
    regMx(:,:,1,z) = abs( ifft2(fftIndReg) ); 
end

ref = uint16(squeeze(mean(regMx, 4)));
regMx = uint16(regMx);

end