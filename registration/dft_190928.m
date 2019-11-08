function [regMovie, refPic, xyshift] = dft_190928(mx, ref_idx, ref_file_name, shift_file_name, refPmt, upscale)
% This dft version don't use predefined ref. It always use own refpic by
% mean of a part of the mx. If give a reg_file_name instead of '', it will
% save the regPic. If five a shift_file_name instead of '', it will save
% the shift parameters in the mat file.
% This dft register movie by multiple pieces.

if nargin < 6, upscale = 10; end
if nargin < 5, refPmt = 0; end
if nargin < 4, shift_file_name = ''; end
if nargin < 3, ref_file_name = ''; end

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


% Start to register by piece. 
% Make the reference images and their Fourier transforms
ref = zeros(size(mx, 1), size(mx, 2), 1, length(ref_idx)-1);
regMovie = zeros(size(mx));
shift = nan(f, 5);% shift = (Nframe x 5 x 3)array of [ xshift, yshift, shift distance, error, phase difference ] 

% Perform registration to whole movie
fprintf('\nStart to register the main pmt...');

for i = 2:length(ref_idx)
    % for each round, first register main pmt by a temp ref.
    sid = ref_idx(i-1)+1;
    eid = ref_idx(i);
    mxpiece = mx(:,:,refPmt,sid:eid);
    refFT = fft2(squeeze(mean(mxpiece, 4))); % this is temp ref

    for z = 1:size(mxpiece, 4)
        indFT = fft2( mxpiece(:,:,1,z) );
        [output, fftIndReg] = dftregistration( refFT, indFT, upscale );
        shift(sid-1+z,1) = output(4); 
        shift(sid-1+z,2) = output(3); 
        shift(sid-1+z,3) = norm(output(3:4)); 
        shift(sid-1+z,4) = output(1); 
        shift(sid-1+z,5) = output(2);
        regMovie(:,:,refPmt,sid-1+z) = abs( ifft2(fftIndReg) ); %have to move this step later
    end
    
    % then output a real piece ref.
    ref(:,:,1, i-1) = squeeze(mean(regMovie(:, :, refPmt, sid:eid), 4));
    %superref = prod(ref>0, 4);
    
    % then apply shift to other channel.
    for j = 1:ch
        if j ~= refPmt
            regMovie(:,:,j,sid:eid) = apply_shift(mx(:,:,j,sid:eid), shift(sid:eid,:));
        end
    end
    disp(['Finished piece ', num2str(i-1)]);
end

%We need super ref for second registration. Right now ref is registered but
%is not super ref as it has edge problem. We need to fix it.
r_shift_min = abs(min(shift(:,2))*upscale);
r_shift_max = max(shift(:,2))*upscale;
c_shift_min = abs(min(shift(:,1))*upscale);
c_shift_max = max(shift(:,1))*upscale;
ref = ref(r_shift_min:end-r_shift_max, c_shift_min:end-c_shift_max, 1, :);
%Now the regMovie has edges. But the ref we want shouldn't have edge.
%before build super ref, we have to crop the edge first.
%regMovie = uint16(regMovie);
%ref = uint16(ref);

% Super ref: Perform registration to refs
errMx = zeros(size(ref,4));
for i = 1:size(ref,4)
    refFT = fft2(ref(:,:,1,i));
    for j = 1:size(ref,4)
        indFT = fft2(ref(:,:,1,j));
        [output, tmp] = dftregistration( refFT, indFT, upscale );
        errMx(i,j) = output(1);
    end
end

[tmp,refidx] = min(mean(errMx,2));
superref = fft2(ref(:,:,1,refidx));
superShift = nan(f, 5);
for i = 1:size(ref,4)
    indFT = fft2(ref(:,:,1,i));
    [output, tmp] = dftregistration(superref, indFT, upscale );
    sid = ref_idx(i)+1;
    eid = ref_idx(i+1);
    superShift(sid:eid,1) = output(4); 
    superShift(sid:eid,2) = output(3); 
    superShift(sid:eid,3) = norm(output(3:4)); 
    superShift(sid:eid,4) = output(1); 
    superShift(sid:eid,5) = output(2);
    
    %for j = 1:ch
    %    regMovie(:,:,j,sid:eid) = apply_shift(regMovie(:,:,j,sid:eid), superShift(sid:eid, :));
    %end
end


% Now apply the superShift to regMovie
for i = 1:ch
    regMovie(:,:,i,:) = apply_shift(regMovie(:,:,i,:), superShift);
end

% Now all step finished
refPic = uint16(squeeze(mean(regMovie(:,:,refPmt,:), 4)));
regMovie = uint16(regMovie);
% this is used for crop ref, not for reg.
xyshift=[shift(:,1)+superShift(:,1), shift(:,2)+superShift(:,2)]; 
xyshift=[abs(min(xyshift(:,1))), max(xyshift(:,2)), abs(min(xyshift(:,2))), max(xyshift(:,2))]*upscale;

if ~strcmp(shift_file_name, '')
    save(shift_file_name, 'shift', 'superShift');
end

if ~strcmp(ref_file_name, '')
    imwrite(refPic, ref_file_name);
end

fprintf('  Done.   ');

end

