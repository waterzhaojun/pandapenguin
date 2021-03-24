function linescan(animal, date, run, varargin)

% This function is to calculate linescan data.

parser = inputParser;
addRequired(parser, 'animal');
addRequired(parser, 'date' );
addRequired(parser, 'run' );
addReguired(parser, 'pmt', 0);
addParameter(parser, 'angle_range', -90:90); % angle range that used to check radon transformation.
addParameter(parser, 'linescanSampleSize', 0.05); % Based on paper https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4962871/, this variable is T. unit is sec
addParameter(parser, 'baselineLength', 1); % The length of period used at the beginning as baseline. unit is sec.
addParameter(parser, 'twod_map_file', '2D_map.tif'); % This file is to identify the angle of the recorded vessel.
parse(parser,animal,date,run,varargin{:});

angle_range = parser.Results.angle_range;
linescanSampleSize = parser.Results.linescanSampleSize; 
baselineLength = parser.Results.baselineLength; 
twod_map_file = parser.Results.twod_map_file;

path = sbxPath(animal, date, run, 'sbx'); 
inf = sbxInfo(path, true);
isarea = inf.area_line;
scanrate = check_scan_rate(inf) * inf.recordsPerBuffer;
xratio = diameter_pixel_ratio(animal, date, run);

if isarea
    error('This trial is not line scan');
end

% Step 1: extract matrix and transform it to the struct as described in method 2.2
mx = mxFromSbxInfo(animal,date,run, pmt);
[stripmx, startidx, endidx] = choose_linescan_strip(mx);

% Step 2: denoise and normalize the image.

backup = stripmx;

stripmx = smoothdata(stripmx, 2);
% for i = 1:size(stripmx, 3)
%     stripmx(:,:,i) = imgaussfilt(stripmx(:,:,i), 9);
% end
baselinemx = stripmx(:,:,1:round(baselineLength / linescanSampleSize)); 
[r,c,f] = size(stripmx);

baselineStripBg = mean(baselinemx, [1,3]);% This is along the r, each point's baseline in 20T time.
stripmx = stripmx  - repmat(baselineStripBg, [r,1,f]); % Need to confirm this step!!

totalBg = mean(stripmx, 'all');
stripmx = stripmx  - totalBg; %- repmat(baselineStripBg, [r,1,f])

% Step 2: search the best angle that represent the blood vessel angle.
angle_array = [];
snr_array = [];
for j = 1:f
    [tmp_angle,tmp_snr,~,~] = radon_transformation(imresize(stripmx(:,:,j),0.5), 'angle_range', angle_range);
    angle_array = [angle_array, tmp_angle];
    snr_array = [snr_array, tmp_snr];
end

% Step 3: convert angle to relative speed. 
speed_relative = tan(angle_array/180 * pi) * scanrate * xratio / 1000; % devide by 1000 is to change unit from um to mm.
% plot(angle_array);
plot(speed_relative);
plot(snr_array);
plot(angle_array);
ylabel('velocity (mm/sec)');

imshow(imadjust(mx(:,startidx:endidx,100)));
imshow(stripmx(:,:,100));

meanVelocity = median(speed_relative)

% Step 4: convert the relative speed to absolute speed by considering the
% vessel's angle.







end