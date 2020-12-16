function diameter_fromMx(mx, path, varargin)

% This function is to analyse diameter from matrix. The matrix's 3rd
% deminsion should be 1. The output ignore whether it is optotune or not. 
% This path is the subfolder in bv root folder. It should have a matrix
% tif, a ref pic, a ref with mask pic etc.
% If the target is vessel trunk, use default vesselType. If it is dive
% part, set vesselType to 'dive'.
% sometimes the video is too noise, then you can set smooth > 0
% This function is mainly used to first time analysis or reset analysis. If
% you just want to add more roi in, please use other function.

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

result = bv_file_system();

% build reference ================================================
if isfile(result.refpath)
    ref = imread([path,result.refpath]); 
else
    ref = imadjust(uint16(squeeze(max(mx,[],4))));
    imwrite(ref, [path,result.refpath]);
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
        ref = addroi(ref, result.roi{roistart}.BW);
        roistart = roistart + 1;
    end
    
end
close;
imwrite(uint16(ref), [path,result.ref_with_mask_path]);

disp('Finished choose roi. Start to calculate diameter array');

% Calculate diameter ==============================================

subplotnum = 2*length(result.roi);
figure();
for i = 1:length(result.roi)
    if strcmp(result.roi{i}.position, 'horizontal')
        [result.roi{i}.diameter, response_fig] = calculate_diameter(mx, result.roi{i}.BW, result.roi{i}.angle);
    elseif strcmp(result.roi{i}.position, 'vertical')
        [result.roi{i}.diameter, response_fig, response_mov] = vertical_diameter_measure(mx, result.roi{i}.BW);
        result.roi{i}.response_mov_path= ['roi_', num2str(i),'_response_mov.tif'];
        %mx2tif(uint8(response_mov/256),[path,result.roi{i}.response_mov_path]);
        % I temperally disable the output 3D tif as sometimes the output
        % has too many frames and cause error. I won't able it again until
        % find a good way to solve it.
    end
    
    subplot(subplotnum, 1, 2*i-1);
    plot(result.roi{i}.diameter);
    xlim([1,length(result.roi{i}.diameter)]);
    
    subplot(subplotnum, 1, 2*i);
    imshow(imresize(uint16(response_fig),[100,1500])); % Right now just use manual way to define ratio. Need to change to a better way.
    
end

saveas(gcf,[path,result.response_fig_path]);
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
mx2tif(mx, [path,result.movpath]);


save([path,result.resultpath], 'result');

end

