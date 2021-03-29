function [velocity, meanVelocity, direction, snr, angles] = linescan(animal, date, run, varargin)

% This function is to calculate linescan data.
% Output:
% velocity: the calculated velocity array.
% meanVelocity: the median blood flow speed.
% direction: The blood flow direction, 1 means from right to left, -1 means
% from left to right.
% snr: the signal to noise ratio for each frame.
% angles: the calculated angle for each frame.

parser = inputParser;
addRequired(parser, 'animal');
addRequired(parser, 'date' );
addRequired(parser, 'run' );
addOptional(parser, 'pmt', 0);
addParameter(parser, 'angle_range', -90:90); % angle range that used to check radon transformation.
addParameter(parser, 'linescanSampleSize', 0.05); % Based on paper https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4962871/, this variable is T. unit is sec
addParameter(parser, 'linescanBlocksPerFrame', 4); % Seperate to how many blocks per frame.
addParameter(parser, 'baselineLength', 1); % The length of period used at the beginning as baseline. unit is sec.
addParameter(parser, 'twod_map_file', '2D_map.tif'); % This file is to identify the angle of the recorded vessel.
addParameter(parser, 'showResult', true, @islogical);
parse(parser,animal,date,run,varargin{:});

pmt = parser.Results.pmt;
angle_range = parser.Results.angle_range;
linescanSampleSize = parser.Results.linescanSampleSize; 
linescanBlocksPerFrame = parser.Results.linescanBlocksPerFrame;
baselineLength = parser.Results.baselineLength; 
twod_map_file = parser.Results.twod_map_file;
showResult = parser.Results.showResult;

path = sbxPath(animal, date, run, 'sbx'); 
inf = sbxInfo(path, true);

outputpath = sbxDir(animal, date, run);
outputpath = [outputpath.runs{1}.base, '_linescan_fig.jpg']; % temperally use this path.

isarea = inf.area_line;
scanrate = check_scan_rate(inf) * inf.recordsPerBuffer;
xratio = diameter_pixel_ratio(animal, date, run);

if isarea
    error('This trial is not line scan');
end

% Step 1: extract matrix and transform it to the struct as described in method 2.2
mx = mxFromSbxInfo(animal,date,run, pmt, 'excludeBeginningSec', 1, 'linescanBlocksPerFrame', linescanBlocksPerFrame, 'linescanSampleSize', linescanSampleSize);
[stripmx, startidx, endidx] = choose_linescan_strip(mx);
stripmx = double(stripmx);

% Step 2: denoise and normalize the image.
[r,c,f] = size(stripmx);
baselinemx = stripmx(:,:,1:min(round(baselineLength / linescanSampleSize),f)); 

baselineStripBg = mean(baselinemx, [1,3]);% This is along the r, each point's baseline in 20T time.
stripmx = stripmx  - repmat(baselineStripBg, [r,1,f]); % Need to confirm this step!!

totalBg = mean(stripmx, 'all');
stripmx = stripmx  - totalBg; 

% Step 3: search the best angle that represent the blood vessel angle.
angles = [];
snr = [];
for j = 1:f
    [tmp_angle,tmp_snr,~,~] = radon_transformation(stripmx(:,:,j), 'angle_range', angle_range);
    angles = [angles, tmp_angle];
    snr = [snr, tmp_snr];
end

% Step 4: convert angle to relative speed. 
tmp = tan(angles/180 * pi) * scanrate * xratio / 1000; % devide by 1000 is to change unit from um to mm.

velocity = abs(tmp);
direction = median(tmp) / abs(median(tmp));
meanVelocity = median(velocity);

if showResult
    figure('Position', [10 10 size(stripmx,2)-100 3*size(stripmx,1) + 100]);
    tiledlayout(3,1)
    
    nexttile;
    plot(velocity);
    hold on
    plot(smooth(velocity));
    yline(meanVelocity)
    hold off
    ylabel('velocity (mm/sec)');
    
    % each frame represent dt = linescanSampleSize / linescanBlocksPerFrame
    dt = linescanSampleSize / linescanBlocksPerFrame;
    x = 1:length(velocity);
    x = x * dt;
    xticks(0:1/dt:length(velocity));
    xticklabels([0:ceil(x(end))]);
    xlabel('time (sec)');

    nexttile;
    yyaxis left
    plot(snr);
    ylabel('SNR');
    yyaxis right
    plot(angles);
    ylabel('angle');
    xticklabels([]);
    
    nexttile;
    %imshow(imadjust(stripmx(:,:,round(f/2))));
    [~,imagef] = max(snr);
    imshow(stripmx(:,:,imagef));
    title(['angle=', num2str(angles(imagef))]);
    
end

exportgraphics(gcf,outputpath);
% savefig(outputpath); If in the future decide to save as fig, use this
% line.




end