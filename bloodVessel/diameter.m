function diameter(animalID, dateID, run, pmt,layer,varargin)
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
z = inf.otparam(3);
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
outputpath = [correct_folderpath(bvpath), foldername];
  
% start to calculate ===================================================
diameter_fromMx(mx, outputpath, 'output_mov_fbint', output_mov_fbint, ...
    'smooth', smooth);


end

