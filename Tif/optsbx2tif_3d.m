function optsbx2tif_3d(animalID, dateID, run, pmt,varargin)
% This function is to build 3D structure of selected pmt channel.
p = inputParser;
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
addRequired(p, 'animalID', @ischar);
addRequired(p, 'dateID', @ischar);
addRequired(p, 'run', validScalarPosNum);
addOptional(p, 'pmt', 0, @(x) any(validatestring(num2str(x),{'0','1'})));
parse(p,animalID, dateID, run, pmt, varargin{:});

if pmt == 0
    fnm = 'greenChl'; 
else
    fnm = 'redChl';
end

path = sbxPath(animalID, dateID, run, 'sbx'); 
inf = sbxInfo(path, true);
if inf.nchan == 1, pmt = 0; end
pmt = pmt + 1;
z = inf.otparam(3);
disp('start to load matrix...');
mx = mxFromSbxPath(path);
[r,c,ch,f] = size(mx);
disp(['original size ', num2str(r), 'x',num2str(c),'x',num2str(ch),'x',num2str(f)]);
mx = mx(:,:,pmt,1:floor(f/z)*z);
[r,c,ch,f] = size(mx);
mx = squeeze(mean(reshape(mx, r,c,ch,z,f/z),5));
mx = reshape(mx, r,c,ch,z);

outputpath = [path(1:end-4), '_', fnm, '_3Dstructure.tif'];
mx2tif(uint16(mx), outputpath);


end