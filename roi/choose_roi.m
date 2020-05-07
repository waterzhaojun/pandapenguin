function choose_roi(im,output_folderpath)

%% load map and mask
if output_folderpath(end) ~= '\'
    output_folderpath = [output_folderpath, '\'];
end

total_mask_path = [output_folderpath, 'totalmask.tif'];
if ~isfile(total_mask_path)
    total_mask = uint16(zeros(size(im,1), size(im,2)));
else
    total_mask = uint16(imread(total_mask_path));
end

%% get identified roi list
filelist = dir([output_folderpath, '\*_*.tif']);
roilist = 1;
for i = 1:length(filelist)
    tmp = strsplit(filelist(i).name,'_');
    tmp = str2num(tmp{1});
    if tmp>=roilist
        roilist = tmp+1;
    end
end

%% start to add new roi
flag = 1;
maskcolor = 'b';

while flag

    refmap = apply_mask(im, total_mask, 0.5);
    imshow(refmap);
    title('After choose roi, press b for branch, s for sito, e for endfeet, q for quit.');
    roi = drawfreehand('color', maskcolor, 'LineWidth', 1);
    msk = uint16(createMask(roi));
%     if sum(msk .* total_mask, 'all') > 0
%         disp('haha');
%     end
%     fname = [output_folderpath, num2str(roilist)];
    w = waitforbuttonpress;
    p = get(gcf, 'CurrentCharacter');
    switch p
        
        case 'b'
            checkfiles = dir([output_folderpath, '\*_sito.tif']);
            disp('selected a branch mask');
            match = 0;
            bigi = 0;
            for i = 1:length(checkfiles)
                tmpmask = imread([output_folderpath, checkfiles(i).name]);
                if sum(msk .* tmpmask, 'all') > match
                    match = sum(msk .* tmpmask, 'all');
                    bigi = i;
                end
            end
            if bigi ~= 0
                fprintf('Conflict with %s.\n',checkfiles(bigi).name);
                msk = msk - msk .* imread([output_folderpath, checkfiles(bigi).name]);
                tmp = strsplit(checkfiles(bigi).name, '_');
                fname = [tmp{1}, '_branch.tif'];
            else
                fname = [num2str(roilist),'_branch.tif'];
                roilist = roilist + 1;
            end
            
        case 's'
            checkfiles = dir([output_folderpath, '\*_branch.tif']);
            disp('selected a sito mask');
            match = 0;
            bigi = 0;
            for i = 1:length(checkfiles)
                tmpmask = imread([output_folderpath, checkfiles(i).name]);
                if sum(msk .* tmpmask, 'all') > match
                    tmpmask = uint16(tmpmask - tmpmask .* msk);
                    imwrite(tmpmask, [output_folderpath, checkfiles(i).name]);
                    match = sum(msk .* tmpmask, 'all');
                    bigi = i;
                end
            end
            disp(bigi);
            if bigi ~= 0
                fprintf('Conflict with %s.\n',checkfiles(bigi).name);
                tmp = strsplit(checkfiles(bigi).name, '_');
                fname = [tmp{1}, '_sito.tif'];
            else
                fname = [num2str(roilist),'_sito.tif'];
                roilist = roilist + 1;
            end
            
        case 'e'
            fname = [num2str(roilist),'_endfeet.tif'];
            disp('selected a endfeet mask');
            roilist = roilist + 1;
            
        case 'k'
            fname = 'background.tif';
            disp('selected a background mask');
            
        case 'q'
            flag = 0;
            break
    end
    
    if flag
        imwrite(uint16(msk), [output_folderpath, fname]);
        total_mask = uint16(((total_mask + msk) > 0)*1);
        imwrite(total_mask, total_mask_path);
    end
end


disp('finished');


end

%% functions

function refmap = apply_mask(im, total_mask, alpha)

    if nargin < 3, alpha = 0.4; end

    if ndims(im) == 2
        refmap = uint16(double(im) .* (1-double(total_mask)*alpha));
    elseif ndims(im) == 3
        for i = 1:size(im, 3)
            refmap(:,:,i) = uint16(double(im(:,:,i)).*(1-double(total_mask)*alpha));
        end
    end

end