function [regMovie, shift] = dft_190928(mx, parameters, ref)
% Register movies
if nargin < 3, ref = ''; end

% Navg = 90;
upscale = 10; 
refPmt = parameters.config.registratePmt;

if ndims(mx) == 3
    [r,c,f] = size(mx);
    mx = reshape(mx, [r,c,1,f]);
end

[r,c,ch,f] = size(mx);

if ch == 1
    refPmt = 1;
elseif ch > 1
    refPmt = refPmt +1; % Please confirm here that pmt = 0 is the first layer of dim 3
end


% Which frames should be averaged to form the reference image?
if strcmp(ref, '')
    refIm = imread(parameters.refname);
else
    refIm = read(ref);
end


% Make the reference images and their Fourier transforms
refFT = fft2(refIm(:,:));
% Perform registration
shift = nan(f, 5);% shift = (Nframe x 5 x 3)array of [ xshift, yshift, shift distance, error, phase difference ] 
regMovie = zeros(r,c,ch,f);

fprintf('\nStart to register the main pmt...');
for z = 1:f
    indFT = fft2( mx(:,:,refPmt,z) );
    [output, fftIndReg] = dftregistration( refFT, indFT, upscale );
    shift(z,1) = output(4); 
    shift(z,2) = output(3); 
    shift(z,3) = norm(output(3:4)); 
    shift(z,4) = output(1); 
    shift(z,5) = output(2);
    regMovie(:,:,refPmt,z) = abs( ifft2(fftIndReg) );
end
save([parameters.basicname, '_registeration_shift.mat'], 'shift');
% if has more than 1 pmts, use the main channel register paratmers to
% register the other channels.
% For this part. I didn't test with a two channel mx.
for otherCh = 1:ch
    
    
    if otherCh ~= refPmt
        disp(sprintf('start to register channel %i...', otherCh));
        Nr = ifftshift( -fix(r/2):ceil(r/2)-1 ); % adapted from dftregistration
        Nc = ifftshift( -fix(c/2):ceil(c/2)-1 ); % adapted from dftregistration
        [Nc,Nr] = meshgrid(Nc,Nr); % adapted from dftregistration
        % Register one color, then apply that registration to the other color
        for z = 1:f
            tmpFT = fft2( mx(:,:,otherCh,z) );
            fftDepReg = tmpFT.*exp(1i*2*pi*(-shift(z,2)*Nr/r-shift(z,1)*Nc/c)); % adapted from dftregistration
            fftDepReg = fftDepReg*exp(1i*shift(z,5)); % adapted from dftregistration
            regMovie(:,:,otherCh,z) = abs( ifft2(fftDepReg) );
        end
    end
end
regMovie = uint16(regMovie);


fprintf('  Done.   ');

end