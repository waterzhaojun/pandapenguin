function choose_roi(im,output_folderpath)

if output_folderpath(end) ~= '\'
    output_folderpath = [output_folderpath, '\'];
end

total_mask_path = [output_folderpath, 'totalmask.tif'];
if ~isfile(total_mask_path)
    total_mask = uint16(zeros(size(im,1), size(im,2)));
else
    total_mask = uint16(imread(total_mask_path));
end

if ndims(im) == 2
    im = uint16(double(im) .* (1-double(total_mask)*0.25));
elseif ndims(im) == 3
    for i = 1:size(im, 3)
        im(:,:,i) = uint16(double(im(:,:,i)).*(1-double(total_mask)*0.25));
    end
end

imshow(im);
title('After choose roi, press b for branch, s for sito, e for endfeet.');
maskcolor = 'b';

filelist = dir([output_folderpath, '\*.tif']);
roilist = 1;
roifilelist = [];
% for i = 1:length(filelist)
%     tmp = split(filelist(i).name, '_');
%     tmp = str2num(tmp{1});
%     if ~ismember(tmp, roilist)
%         roilist = [roilist, tmp];
%     end
% end
for i = 1:length(filelist)
    if length(regexp(filelist(i).name, '[0-9]*_.*.tif')) > 0
        roifilelist = [roifilelist, filelist(i)];
        roilist = roilist+1;
    end
end
    
    

roi = drawfreehand('color', maskcolor);
msk = uint16(createMask(roi));
fname = [output_folderpath, num2str(roilist)];
while true
    w = waitforbuttonpress;
    p = get(gcf, 'CurrentCharacter');
    switch p
        case 'b'
            fname = [fname, '_branch.tif'];
            disp('selected a branch mask');
            break
        case 's'
            fname = [fname, '_sito.tif'];
            disp('selected a sito mask');
            break
        case 'e'
            fname = [fname, '_endfeet.tif'];
            disp('selected a endfeet mask');
            break
        case 'k'
            fname = ['background.tif'];
            disp('selected a background mask');
            break
    end
end


imwrite(uint16(msk), fname);

newtotalmask = ((total_mask + msk) > 0)*1;
imwrite(uint16(newtotalmask), total_mask_path);

for i = 1:length(roifilelist)
    tmppath = [roifilelist(i).folder, '\', roifilelist(i).name];
    tmpim = uint16(imread(tmppath));
    tmpim = ((tmpim - msk)>0)*1;
    if sum(tmpim, [1,2]) ~= 0
        imwrite(uint16(tmpim), tmppath);
    end
end


end