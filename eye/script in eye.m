path = 'D:\Jun 2Photon\DL72\170723_DL72\170723_DL72_run5\DL72_170723_005_eye.mat';
img = load(path);
img = squeeze(img.data);
img1 = bint(img,31);
img1 = img1/255;
writetiffJun(img1, [path(1:end-3), 'tif']);

sbxPath('DL72', '170723', 2, 'sbx')
optsbx2tif('DL72', '170723', 3,1,0,[0,0.9]);