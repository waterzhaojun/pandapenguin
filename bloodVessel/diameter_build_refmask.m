function result = diameter_build_refmask(folder,mx,varargin)
% This function is to build a ref map and choose roi mask. If ref.tif
% already exist, it will just load the tif. You can also rebuild the ref by
% set 'rebuildRef' 1. If result.mat already exist and has several roi, this
% function will add roi in result.mat. If you want to reset rois, set
% 'rebuildRoi' 1. 
parser = inputParser;
addRequired(parser, 'folder', @ischar );
addRequired(parser, 'mx');
addParameter(parser, 'rebuildRef', false, @islogical);
addParameter(parser, 'rebuildRoi', false, @islogical);
parse(parser,folder, mx, varargin{:});

filesys = bv_file_system();

folder = correct_folderpath(folder);

refpath = [folder, filesys.refpath];
if ~isfile(refpath) || parser.Results.rebuildRef
    ref = imadjust(uint16(squeeze(max(mx,[],4))));
    imwrite(ref, refpath);
else
    ref = imread(refpath); 
end

resultpath = [folder, filesys.resultpath];
if ~isfile(resultpath) || parser.Results.rebuildRoi
    result = struct();
    result.movpath = filesys.movpath;
    result.refpath = filesys.refpath;
    result.ref_with_mask_path = filesys.ref_with_mask_path;
    result.resultpath = filesys.resultpath;
    result.response_fig_path = filesys.response_fig_path;
    result.roi = {};
    
    % build mask =====================================================
    flag = 1;
    roistart = 1 + length(result.roi);

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
    imwrite(uint16(ref), [folder,result.ref_with_mask_path]);
    save([folder, result.resultpath], 'result');
    
else
    result = load(resultpath);
    result = result.result;
    % ref = imread([folder,result.ref_with_mask_path]);
end





disp('Finished choose/load roi. You can start to calculate diameter array');

end