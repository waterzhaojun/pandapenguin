function [regMx, shift]=dft_piece_registration(refs, upscale)

% This function is mainly used to registrate ref pic by pick up one from
% several ref pics as main ref pic, then registrate the others by it.
% the refs should have a clean edge, otherwise it might caught problem.

if length(size(refs)) <4
    error('refs should have 4 dims.');
end

[r,c,ch,f] = size(refs);
if ch >1, error('ref should only have one channel'); end

errMx = zeros(f);
for i = 1:f
    refFT = fft2(refs(:,:,1,i));
    for j = 1:f
        indFT = fft2(refs(:,:,1,j));
        [output, tmp] = dftregistration( refFT, indFT, upscale );
        errMx(i,j) = output(1);
    end
end

[tmp,refidx] = min(mean(errMx,2));
refFt = fft2(refs(:,:,1,refidx));
shift = nan(f, 5);
regMx = zeros(r,c,1,f);
for i = 1:f
    indFT = fft2(refs(:,:,1,i));
    [output, fftIndReg] = dftregistration(refFt, indFT, upscale );
    shift(i,1) = output(4); 
    shift(i,2) = output(3); 
    shift(i,3) = norm(output(3:4)); 
    shift(i,4) = output(1); 
    shift(i,5) = output(2);
    regMx(:,:,1,i) = abs( ifft2(fftIndReg) ); 
end

regMx = uint16(regMx);


end