function ref = build_registration_ref(animal, date, runs, method)

% This function suppose the series of sbx have the same width and height
% and channel numbers.
gap = 4;

if nargin < 4, method = 'single'; end

for i = 1:length(runs)
    p = load_parameters(animal, date, runs(i));
    registratePmt = p.config.registratePmt + 1;
    outputpath = [p.refname];
    mx = feval(p.config.fn_extract, p);
    mx = feval(p.config.fn_crop, mx, p);
    f = size(mx, 4);
    meanidx = 1:gap:f;
    
    tmp = squeeze(mean(mx(:,:,registratePmt,meanidx), 4));
    ref(:,:,1, i) = uint16(tmp);
end

if strcmp(method, 'multiple') % all runs build one ref pic
    disp('Start to registrate based on a super ref');
    totalref = get_ref_in_multiple(ref);
    ref = dft_190928(ref, totalref, '', 1);
    ref = uint16(ref);
end

for i = 1:size(ref, 4)
    p = load_parameters(animal, date, runs(i));
    outputpath = [p.refname];
    %imwrite(uint16(refmean), outputpath, 'tiff');
    imwrite(squeeze(ref(:,:,1,i)), outputpath, 'tiff');
end

end

function [ref,idx] = get_ref_in_multiple(mx)

[r,c,ch,f] = size(mx);
idx = ceil(f/2);
ref = squeeze(mx(:,:,1, idx));

end