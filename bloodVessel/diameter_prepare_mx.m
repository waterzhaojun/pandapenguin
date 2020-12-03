function mx = diameter_prepare_mx(animalID, dateID, run, pmt,layer,varargin)
% This function is the main function to do vascular analysis by giving exp
% info. If your input is matrix, please use diameter_fromMx.
parser = inputParser;
addRequired(parser, 'animalID', @ischar );
addRequired(parser, 'dateID', @ischar);
addRequired(parser, 'run', @(x) isnumeric(x) && isscalar(x) && (x>0));
addOptional(parser, 'pmt', 0, @(x) isnumeric(x) && isscalar(x) && (x>=0) && (x<2));
addOptional(parser, 'layer', 'all');
addParameter(parser, 'smooth', 0, @(x) isnumeric(x) && isscalar(x) && (x >= 0));
addParameter(parser, 'output_mov_fbint', 1, @(x) isnumeric(x) && isscalar(x) && (x >= 0));

%addParameter(parser, 'output_response_fig_width', 1000, @(x) isnumeric(x) && isscalar(x) && (x > 0)); % The output is not exactly 1000px, but close to 1000 based on the bint size.
parse(parser,animalID, dateID, run, pmt, layer, varargin{:});

smooth = parser.Results.smooth;
output_mov_fbint = parser.Results.output_mov_fbint;

% Prepare data matrix ================================================
path = sbxPath(animalID, dateID, run, 'sbx'); 
inf = sbxInfo(path, true);
if length(inf.otparam) == 3
    z = inf.otparam(3);
else
    z = 1; % if it is single layer, set z to 1.
end
mx = mxFromSbxInfo(animalID, dateID, run, pmt);
[r,c,ch,f] = size(mx);
if z > 1
    f = floor(f/z)*z;
    mx = mx(:,:,:,1:f);
    mx = reshape(mx, r,c,ch,z,f/z);
    if strcmp(layer, 'all')
        layer = 2:z-1;
    end
    mx = squeeze(mean(mx(:,:,:,layer,:), 4));
    mx = reshape(mx, r,c,ch,[]);
end


[r,c,ch,f] = size(mx);
% pretreat mx =========================================================
if smooth > 1
    for i = 1:f
        mx(:,:,1,i) = imgaussfilt(mx(:,:,1,i), smooth);
        %mx(:,:,1,i) = wiener2(mx(:,:,1,i), [smooth, smooth]);
    end
end

% Prepare output path ===================================================
bvpath = [correct_folderpath(fileparts(path)),'bv'];
if ~exist(bvpath, 'dir')
   mkdir(bvpath)
end

if z == 1
    foldername = '1';
else
    foldername = [num2str(layer(1)), 'to', num2str(layer(end))];
end
outputpath = correct_folderpath([correct_folderpath(bvpath), foldername]);

% Save mov sample. If it is single plate recording, we can't save that big
% tiff, so we have to bint it. If it is z stack recording, save a not bint
% movie will be better.
if output_mov_fbint > 1
    samplemov_f = floor(f/output_mov_fbint)*output_mov_fbint;
    mx = mx(:,:,:,1:samplemov_f);
    mx = reshape(mx, r,c,ch,output_mov_fbint,[]);
    mx = squeeze(mean(mx, 4));
    mx = reshape(mx, r,c,ch,[]);
end
mx = uint16(mx);
mx2tif(mx, [outputpath,'mov.tif']);



end