function [mx, outputpath] = diameter_prepare_mx(animalID, dateID, run, varargin)
% This function is the main function to do vascular analysis by giving exp
% info. If your input is matrix, please use diameter_fromMx.
parser = inputParser;
addRequired(parser, 'animalID', @ischar );
addRequired(parser, 'dateID', @ischar);
addRequired(parser, 'run', @(x) isnumeric(x) && isscalar(x) && (x>0));
addOptional(parser, 'pmt', 0, @(x) isnumeric(x) && isscalar(x) && (x>=0) && (x<2));
addParameter(parser, 'layer', 'all');
addParameter(parser, 'smooth', 0, @(x) isnumeric(x) && isscalar(x) && (x >= 0));
addParameter(parser, 'output_mov', true, @islogical);
addParameter(parser, 'output_mov_fs', 1, @(x) isnumeric(x) && isscalar(x) && (x >= 0)); % suppose output 1hz mov.

%addParameter(parser, 'output_response_fig_width', 1000, @(x) isnumeric(x) && isscalar(x) && (x > 0)); % The output is not exactly 1000px, but close to 1000 based on the bint size.
parse(parser,animalID, dateID, run, varargin{:});

pmt = parser.Results.pmt;
layer = parser.Results.layer;
smooth = parser.Results.smooth;
output_mov = parser.Results.output_mov;
output_mov_fs = parser.Results.output_mov_fs;

% Prepare data matrix ================================================
path = sbxPath(animalID, dateID, run, 'sbx'); 
inf = sbxInfo(path, true);
z = check_scan_layers(inf);
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
if ~exist(outputpath, 'dir')
   mkdir(outputpath)
end

% Save mov sample. This sample is used only to check, not for future check.
% The rate is 1hz.
if output_mov
    output_mov_fbint = round(check_scan_rate(inf) / check_scan_layers(inf) / output_mov_fs);
    samplemov_f = floor(f/output_mov_fbint)*output_mov_fbint;
    mxmov = mx(:,:,:,1:samplemov_f);
    if output_mov_fbint > 1
        disp(['bint by ', num2str(output_mov_fbint), ' the mx to output sample mov']);


        mxmov = reshape(mxmov, r,c,ch,output_mov_fbint,[]);
        mxmov = squeeze(mean(mxmov, 4));
        mxmov = reshape(mxmov, r,c,ch,[]);
    elseif output_mov_fbint < 1
        disp(['Cannot bint by ', num2str(output_mov_fbint), '. Just save not bint sample mov.']);
    end
    mxmov = uint16(mxmov);
    mx2tif(mxmov, [outputpath,'mov.tif']);
end



end