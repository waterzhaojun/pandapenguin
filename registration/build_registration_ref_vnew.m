function ref = build_registration_ref_vnew(animal, date, run, pmt, varargin)

% This function is to build ref for single trial. It is just a temperary
% function
parser = inputParser;
addRequired(parser, 'animal', @ischar );
addRequired(parser, 'date', @ischar);
addRequired(parser, 'run', @(x) isnumeric(x) && isscalar(x) && (x>0));
addRequired(parser, 'pmt', @(x) isnumeric(x) && isscalar(x) && (x>=0) && (x<=2));
parse(parser,animal,date,run,pmt,varargin{:});

rpath = sbxDir(animal, date, run);
rpath = rpath.runs{1};
inf = sbxInfo(rpath.info, true);
z = check_scan_layers(inf);
mx = mxFromSbxInfo(animal,date,run,pmt);
[r,c,ch,f] = size(mx);
if rem(f,z) ~= 0
    mx = mx(:,:,:,1:f-rem(f,z));
end
    
mx = reshape(mx, r,c,ch,z,[]);
ref = squeeze(mean(mx, 5));
%ref = reshape(ref, size(mx,1), size(mx,2), size(mx,3), z);
ref = uint16(ref);

writeSingleTif(ref, rpath.registration_ref);


end