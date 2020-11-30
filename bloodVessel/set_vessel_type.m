function set_vessel_type(folderpath)
folderpath = correct_folderpath(folderpath);
resultpath = [folderpath, 'result.mat'];
result = load(resultpath);
result = result.result;
ref_with_mask = imread([folderpath, 'ref_with_mask.tif']);

% in case some warning may interrupt the input, we just stop it.
warning('off','all')

for i = 1:length(result.roi)
    roi = result.roi{i};
    [center_r,center_c] = bwcenter(roi.BW);
    imshow(ref_with_mask);
    title('set vessel type, a for artery, v for vein');
    hold on
    scatter(center_c, center_r, 'fill', 'MarkerFaceColor',[0,1,0]);
    hold off
    waitforbuttonpress;
    p = get(gcf, 'CurrentCharacter');
    disp(strcmp(p,' '));
    if strcmp(p, 'a')
        result.roi{i}.type='artery';
    elseif strcmp(p, 'v')
        result.roi{i}.type='vein';
    else
        error('Please choose correct type');
    end
    
    title('set tissue type, d for dura, p for pia, c for cortex');
    waitforbuttonpress;
    pp = get(gcf, 'CurrentCharacter');
    if strcmp(pp, 'd')
        result.roi{i}.tissue='dura';
    elseif strcmp(pp, 'p')
        result.roi{i}.tissue='pia';
    elseif strcmp(pp, 'c')
        result.roi{i}.tissue='cortex';
    else
        error('Please choose correct type');
    end
end

save(resultpath, 'result');

end