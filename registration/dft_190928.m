function [regMovie, shift, superShift, ref_clean, superRef] = dft_190928(mx, ref_idx, refPmt, upscale)
% This dft version don't use predefined ref. It always use own refpic by
% mean of a part of the mx. If give a reg_file_name instead of '', it will
% save the regPic. If five a shift_file_name instead of '', it will save
% the shift parameters in the mat file.
% This dft register movie by multiple pieces.

if nargin < 4, upscale = 10; end
if nargin < 3, refPmt = 0; end

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
    [regMovie(:,:,refPmt,sid:eid), shift(sid:eid, :), ref(:,:,1,i-1)] = dft_trunk_registration(mxpiece, upscale);
    disp(['Finished piece ', num2str(i-1), ' of ' num2str(length(ref_idx)-1)]);
end
    
% then apply shift to other channel.
for j = 1:ch
    if j ~= refPmt
        regMovie(:,:,j,:) = apply_shift(mx(:,:,j,:), shift);
    end
end


%We need super ref for second registration. Right now ref is registered but
%is not super ref as it has edge problem. We need to fix it.

ref_clean = dft_clean_edge(ref, shift); % I am not sure the crop is correct.

[ref_clean, superShift] = dft_piece_registration(ref_clean, upscale);
superShift = dft_expand_shift(superShift, ref_idx);


% Now apply the superShift to regMovie
for i = 1:ch
    regMovie(:,:,i,:) = dft_apply_shift(regMovie(:,:,i,:), superShift);
end

% Now all step finished
superRef = uint16(squeeze(mean(regMovie(:,:,refPmt,:), 4)));
ref_clean = uint16(ref_clean);
regMovie = uint16(regMovie);
% this is used for crop ref, not for reg.
% superRef_xyshift=[shift(:,1)+superShift(:,1), shift(:,2)+superShift(:,2)]; 
% superRef_xyshift=[min(superRef_xyshift(:,1)), max(superRef_xyshift(:,2)), min(superRef_xyshift(:,2)), max(superRef_xyshift(:,2))]*upscale;



fprintf('  Done.   ');

end

