function diameter(animalID, dateID, run, varargin)
% This function is the main function to do vascular analysis by giving exp
% info. If your input is matrix, please use diameter_fromMx.
parser = inputParser;
addRequired(parser, 'animalID', @ischar );
addRequired(parser, 'dateID', @ischar);
addRequired(parser, 'run', @(x) isnumeric(x) && isscalar(x) && (x>0));
addOptional(parser, 'pmt', 0, @(x) isnumeric(x) && isscalar(x) && (x>=0) && (x<2));
addOptional(parser, 'layer', 'all');
addParameter(parser, 'smooth', 0, @(x) isnumeric(x) && isscalar(x) && (x >= 0));
%addParameter(parser, 'output_mov_fbint', 1, @(x) isnumeric(x) && isscalar(x) && (x >= 0));
%addParameter(parser, 'output_response_fig_width', 1000, @(x) isnumeric(x) && isscalar(x) && (x > 0)); % The output is not exactly 1000px, but close to 1000 based on the bint size.
parse(parser,animalID, dateID, run, varargin{:});

pmt = parser.Results.pmt;
layer = parser.Results.layer;
smooth = parser.Results.smooth;
%output_mov_fbint = parser.Results.output_mov_fbint;

% Prepare data matrix and output bint =====================================
path = sbxPath(animalID, dateID, run, 'sbx'); 
inf = sbxInfo(path, true);
if inf.volscan == 1
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

if inf.scanmode == 1
    output_mov_fbint = 15/z;
elseif inf.scanmode == 2  
    output_mov_fbint = 31/z;
end
    

% Prepare output path ===================================================
bvfilesys = bv_file_system();
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

% add some extra info in ===========================================
result = load([correct_folderpath(outputpath), bvfilesys.resultpath]);
result = result.result;
if inf.scanmode == 1
    tmpscanrate = 15;
elseif inf.scanmode == 2
    tmpscanrate = 31;
end
if inf.volscan == 1
    tmplayers = inf.otparam(3);
else
    tmplayers = 1; % if it is single layer, set z to 1.
end
result.scanrate = tmpscanrate / tmplayers;
save([correct_folderpath(outputpath), bvfilesys.resultpath], 'result');

end

