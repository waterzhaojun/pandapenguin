function diameter_fromMx(mx, path, varargin)

% This function is to analyse diameter from matrix. The matrix's 3rd
% deminsion should be 1. The output ignore whether it is optotune or not. 
% This path is the subfolder in bv root folder. It should have a matrix
% tif, a ref pic, a ref with mask pic etc.
% If the target is vessel trunk, use default vesselType. If it is dive
% part, set vesselType to 'dive'.
% sometimes the video is too noise, then you can set smooth > 0

parser = inputParser;
addRequired(parser, 'mx', @(x) isnumeric(x) && (size(x,3)== 1) );
addRequired(parser, 'path', @ischar);
%addParameter(p, 'vesselType', 'trunk', @(x) any(validatestring(x,{'trunk', 'dive'})));
addParameter(parser, 'smooth', 0, @(x) isnumeric(x) && isscalar(x) && (x >= 0));
addParameter(parser, 'output_mov_fbint', 1, @(x) isnumeric(x) && isscalar(x) && (x >= 0));
%addParameter(parser, 'output_response_fig_width', 1000, @(x) isnumeric(x) && isscalar(x) && (x > 0)); % The output is not exactly 1000px, but close to 1000 based on the bint size.
parse(parser,mx, path, varargin{:});

smooth = parser.Results.smooth;
output_mov_fbint = parser.Results.output_mov_fbint;

[r,c,ch,f] = size(mx);
% pretreat mx =========================================================
if smooth > 1
    for i = 1:f
        mx(:,:,1,i) = imgaussfilt(mx(:,:,1,i), smooth);
        %mx(:,:,1,i) = wiener2(mx(:,:,1,i), [smooth, smooth]);
    end
end

% set a result struct =================================================
path = correct_folderpath(path);
if ~exist(path, 'dir')
   mkdir(path)
end

result = struct();
result.movpath = [path,'mov.tif'];
result.refpath = [path,'ref.tif'];
result.ref_with_mask_path = [path, 'ref_with_mask.tif'];
result.resultpath = [path, 'result.mat'];
result.response_fig_path = [path, 'response.pdf'];

result.roi = {};

% build reference ================================================
if isfile(result.refpath)
    ref = imread(result.refpath); 
else
    ref = imadjust(uint16(squeeze(max(mx,[],4))));
    imwrite(ref, result.refpath);
end

% build mask =====================================================
flag = 1;
roistart = 1;

while flag
    [BW,angle] = bwangle(ref, 'title','After choose roi, Please choose vessel position. Press t for horizontal trunk, v for vertical penetration, q to quit');
    waitforbuttonpress;
    p = get(gcf, 'CurrentCharacter');
    switch p
        case 't'
            vposition='horizontal';
            
        case 'v'
            vposition='vertical';
            
        case 'q'
            flag = 0;
    end
    if ~strcmp(p,'q')
        result.roi{roistart}.position = vposition;
        if strcmp(p,'t')
            result.roi{roistart}.BW = BW;
            result.roi{roistart}.angle = angle;
        elseif strcmp(p,'v')
            result.roi{roistart}.BW = vertical_mask(BW);
        end
        ref = addroi(ref, BW);
        roistart = roistart + 1;
    end
    
end
close;
imwrite(uint16(ref), result.ref_with_mask_path);

disp('Finished choose roi. Start to calculate diameter array');

% Calculate diameter ==============================================

subplotnum = 2*length(result.roi);
figure();
for i = 1:length(result.roi)
    if strcmp(result.roi{i}.position, 'horizontal')
        [result.roi{i}.diameter, response_fig] = calculate_diameter(mx, result.roi{i}.BW, result.roi{i}.angle);
    elseif strcmp(result.roi{i}.position, 'vertical')
        [result.roi{i}.diameter, response_fig] = vertical_diameter_measure(mx, result.roi{i}.BW);
    end
    
    subplot(subplotnum, 1, 2*i-1);
    plot(result.roi{i}.diameter);
    xlim([1,length(result.roi{i}.diameter)]);
    
    subplot(subplotnum, 1, 2*i);
    imshow(imresize(uint16(response_fig),[100,1500])); % Right now just use manual way to define ratio. Need to change to a better way.
    
end

saveas(gcf,result.response_fig_path);
close;

% output mov sample ===============================================
if output_mov_fbint > 1
    samplemov_f = floor(f/output_mov_fbint)*output_mov_fbint;
    mx = mx(:,:,:,1:samplemov_f);
    mx = reshape(mx, r,c,ch,output_mov_fbint,[]);
    mx = squeeze(mean(mx, 4));
    mx = reshape(mx, r,c,ch,[]);
end
mx = uint16(mx);
mx2tif(mx, result.movpath);


save(result.resultpath, 'result');

end

