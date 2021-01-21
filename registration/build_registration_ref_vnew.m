function ref = build_registration_ref_vnew(animal, date, run, pmt, varargin)

% This function is to build ref for single trial. 
parser = inputParser;
addRequired(parser, 'animal', @ischar );
addRequired(parser, 'date', @ischar);
addRequired(parser, 'run', @(x) isnumeric(x) && isscalar(x) && (x>0));
addRequired(parser, 'pmt', @(x) isnumeric(x) && isscalar(x) && (x>=0) && (x<=2));
parse(parser,animal,date,run,pmt,varargin{:});

path = sbxPath(animal, date, run, 'sbx'); 
inf = sbxInfo(path, true);
z = check_scan_layers(inf);
mx = mxFromSbxInfo(animal,date,run,pmt);
[r,c,ch,f] = size(mx);
if rem(f,z) ~= 0
    mx = mx(:,:,:,1:f-rem(f,z));
end
    
mx = reshape(mx, r,c,ch,z,[]);
ref = mean(mx, 5);
ref = reshape(ref, size(mx,1), size(mx,2), size(mx,3), z);

writeSingleTif(ref, );
for i = 1:size


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