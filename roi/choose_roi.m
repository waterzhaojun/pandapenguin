function choose_roi(im,output_folderpath,edgeshift)


if nargin < 3
    shiftmask = ones(size(im,1), size(im,2));
else
    r = size(im,1);
    c = size(im,2);
    shiftmask = ones(size(im,1), size(im,2));
    r_start=[]; r_end=[]; c_start=[]; c_end=[];
    for i = 1:length(edgeshift)
        shift = edgeshift{i};
        r_start = [r_start, 1 + ceil(max(shift(:,2) .* (shift(:,2)>0)))];
        r_end = [r_end, r - ceil(abs(min(shift(:,2) .* (shift(:,2)<0))))];
        c_start = [c_start, 1 + ceil(max(shift(:,1) .* (shift(:,1)>0)))];
        c_end = [c_end, c - ceil(abs(min(shift(:,1) .* (shift(:,1)<0))))];
    end

    r_start = max(r_start);
    r_end = min(r_end);
    c_start = max(c_start);
    c_end = min(c_end);
    shiftmask(1:r_start-1,:) = 0;
    shiftmask(r_end+1:end,:) = 0;
    shiftmask(:,1:c_start-1) = 0;
    shiftmask(:,c_end+1:end) = 0;
end

%% load map and mask
if output_folderpath(end) ~= '\'
    output_folderpath = [output_folderpath, '\'];
end

total_mask_path = [output_folderpath, 'totalmask.tif'];
total_mask = uint16(zeros(size(im,1), size(im,2)));
size(total_mask)

%if ~isfile(total_mask_path)
%    total_mask = uint16(zeros(size(im,1), size(im,2)));
%else
%    total_mask = uint16(imread(total_mask_path));
%end

%% get identified roi list
filelist = dir([output_folderpath, '*_*.tif']);

roilist = 1;
for i = 1:length(filelist)
    tmp = strsplit(filelist(i).name,'_');
    tmp = str2num(tmp{1});
    if tmp>=roilist
        roilist = tmp+1;
    end
    
    tmpmsk = imread([filelist(i).folder,'\',filelist(i).name]);
    total_mask = uint16(((total_mask + tmpmsk) > 0)*1);
end

disp('done');

%% start to add new roi
flag = 1;
maskcolor = 'b';

while flag

    refmap = apply_mask(im, total_mask, 0.5);
    imshow(refmap);
    title('After choose roi, press b for branch, s for sito, e for endfeet, q for quit.');
    roi = drawfreehand('color', maskcolor, 'LineWidth', 1);
    msk = uint16(createMask(roi).*shiftmask);
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