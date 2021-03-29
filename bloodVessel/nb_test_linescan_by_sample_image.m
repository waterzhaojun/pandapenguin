mx = loadTiffStack_slow('C:\Users\jzhao1\Documents\pandapenguin\packages\HybridVel\fig9im.tif');

linescanSampleSize = 0.05 % sec
scanrate = 15.5;
recordsPerBuffer = 512;

Tr = round(linescanSampleSize * scanrate * recordsPerBuffer / 4) * 4;
Tr = 100;
mx = uint16(linescanTransform(mx, Tr));

[stripmx, startidx, endidx] = choose_linescan_strip(mx);
stripmx = double(stripmx);
% Step 2: denoise and normalize the image.

backup = stripmx;

% stripmx = smoothdata(stripmx, 2);
% for i = 1:size(stripmx, 3)
%     stripmx(:,:,i) = imgaussfilt(stripmx(:,:,i), 9);
% end
baselinemx = stripmx(:,:,:); 
[r,c,f] = size(stripmx);

baselineStripBg = mean(baselinemx, [1,3]);% This is along the r, each point's baseline in 20T time.
stripmx = stripmx  - repmat(baselineStripBg, [r,1,f]); % Need to confirm this step!!

totalBg = mean(stripmx, 'all');
stripmx = stripmx  - totalBg; %- repmat(baselineStripBg, [r,1,f])

angle_range = -90:90;
% Step 2: search the best angle that represent the blood vessel angle.
angle_array = [];
snr_array = [];
for j = 1:f
    [tmp_angle,tmp_snr,~,~] = radon_transformation(imresize(stripmx(:,:,j),0.5), 'angle_range', angle_range);
    angle_array = [angle_array, tmp_angle];
    snr_array = [snr_array, tmp_snr];
end

% Step 3: convert angle to relative speed. 
speed_relative = abs(tan(angle_array/180 * pi)) * scanrate * xratio / 1000; % devide by 1000 is to change unit from um to mm.
% plot(angle_array);
plot(speed_relative);
plot(snr_array);
plot(angle_array);
ylabel('velocity (mm/sec)');