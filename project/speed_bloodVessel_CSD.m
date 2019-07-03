animalID = 'DL92';
dateID = '180226';
runs = [1,2,3];
baseruns = [1];

% In this project, I set the frequency to 1 Hz. the scan freq is 15
% frames/sec. I don't want to change to 30 as I tried 30 before, very easy
% to bleaching.
scan_freq = 15;

% project report file struct part===============================================================================================
% ==============================================================================================================================
main_dir = sbxDir(animalID, dateID);
folder_name = 'bloodVessel_response';
project_dir = [main_dir.date_mouse, folder_name, '\'];
working_dir = [project_dir, 'working_dir', '\'];

if exist(project_dir, 'dir') ~= 7
    mkdir(project_dir);
end

if exist(working_dir, 'dir') ~= 7
    mkdir(working_dir);
end

% create a note for the project=================================================================================================
% ==============================================================================================================================
f = fopen([project_dir, 'note.txt'], 'w');

fprintf(f, 'total trials: %s\r\n', vector2str(runs, ','));
fprintf(f, 'baseline trials: %s\r\n', vector2str(baseruns, ','));


total_record_period = 0;
freqs = [];
for i = 1:length(runs)
    tmp = load(sbxPath(animalID, dateID, runs(i), 'info'));
    total_record_period = total_record_period + tmp.info.config.frames/size(tmp.info.otwave,2)/60;
    freqs = [freqs, 15/size(tmp.info.otwave,2)];
end


base_record_period = 0;
for i = 1:length(baseruns)
    tmp = load(sbxPath(animalID, dateID, runs(i), 'info'));
    base_record_period = base_record_period + tmp.info.config.frames/size(tmp.info.otwave,2)/60;
end
fprintf(f, 'baseline recording time: %d min\r\n', base_record_period);
fprintf(f, 'response recording time: %d min\r\n', total_record_period-base_record_period);

if range(freqs)==0
    fprintf(f, 'scan frequency: %d Hz\r\n', freqs(1));
else
    fprintf(f, 'scan frequency: freq changed in runs. Each trial freq is %s \r\n', vector2str(freqs, ' Hz,'));
end



% speed part====================================================================================================================
% ==============================================================================================================================
total_runs = [];
for i = 1:length(runs)
    tmp_var = load(main_dir.runs{i}.quad);
    tmp_var = quad2speed(tmp_var.quad_data);
    tmp_var = binVector(tmp_var, scan_freq); % now I suppose for each trial the scan rate is the same. If not, come back here to modify.
    total_runs = [total_runs, tmp_var];
end

speed_file_name = 'speed.csv';
csvwrite([project_dir, '\', speed_file_name],total_runs);

% blood vessel part=============================================================================================================
% ==============================================================================================================================
% be sure you have produced the tif, and renamed the tif to *bv.tif for
% each run.
% 1. check the max pic of every trial. I suppose the image doesn't move. 
% step 1: draw roi
for i = 1:length(runs)
    tmp_path = dir([main_dir.runs{i}.path, '*bv.tif']);
    tmp_path = [tmp_path.folder, '\', tmp_path.name];
    tmp_mov = loadTifStack(tmp_path);
    tmp_refpic_total(:,:,i) = max(tmp_mov(:,:,:), [], 3);
end
ref_pic = max(tmp_refpic_total(:,:,:), [], 3);
ref_pic = changeTifType(ref_pic);
clearvars tmp_refpic_total tmp_path tmp_mov;
imwrite(ref_pic, [working_dir, 'ref_dir.tif']); % at here, the image might not be seen in Windows. If this happens, script to add uint8.

% if we want to choose different blood vessel, repeat the following part,
% but don't need to repeatly produce ref_pic.
nroi = 2 % change here if more than 1 roi.
ref_pic = imread([working_dir, 'ref_dir.tif']);
[BW, xi, yi] = roipoly(ref_pic); % xi = col, yi = row
BW = double(BW);
imwrite(BW, [working_dir, 'roi_', num2str(nroi), '.tif']); 

% if want to re-run the previous roi, need to load the mask at here.And be
% careful the xi, yi. Now I don't think it is necessary.

% stop at here check tomorrow
BW(uint16(yi(1)), uint16(xi(1))) = 11;
BW(uint16(yi(2)), uint16(xi(2))) = 22;
BW(uint16(yi(3)), uint16(xi(3))) = 33;

xm = xi(2)-xi(1);
ym = yi(2)-yi(1);
angel = asin(ym/sqrt(xm*xm+ym*ym))*180/pi;

BW = imrotate(BW, angel);
[p1r,p1c]=find(BW == 11);
[p2r,p2c]=find(BW == 22);
[p3r,p3c]=find(BW == 33);

final_topo = [];
final_tl = [];

for i=1:length(runs)
    tmp_path = dir([main_dir.runs{i}.path, '*bv.tif']);
    tmp_path = [tmp_path.folder, '\', tmp_path.name];
    tmp_mov = loadTifStack(tmp_path);
    tmp_mov = imrotate(tmp_mov,angel);
%     BW = imrotate(BW, angel);
%     [p1r,p1c]=find(BW == 11);
%     [p2r,p2c]=find(BW == 22);
%     [p3r,p3c]=find(BW == 33);
    tmp_mov = tmp_mov(min(p1r, p2r):p3r, p1c:max(p2c, p3c),:);
%    imshow(tmp_mov(:,:,1));

    tmp_topo = [];
    tmp_tl = [];
    for i = 1:size(tmp_mov,3)
        tmp_topo(:,i) = mean(tmp_mov(:,:,i), 1);
        tmp_tl = [tmp_tl,findEdge(tmp_topo(:,i))];
    end
    
    if(i == 1)
        final_topo = tmp_topo;
    else
        final_topo = cat(2, final_topo, tmp_topo);
    end
    final_tl = [final_tl, tmp_tl];
    
    clearvars tmp_path tmp_mov tmp_topo tmp_tl;
end

save([project_dir, 'bv_change_fig_', int2str(nroi), '.mat'], 'final_topo');


for i=1:length(final_tl)
    if (~(final_tl(i)>0))
        final_tl(i) = final_tl(i-1);
    end
end
% output the data to local folder
output_filename = [project_dir, 'bf_diamater_timeline_', int2str(nroi), '.csv'];
csvwrite(output_filename,final_tl);

plot(total_runs);
hold on;
plot(final_tl);
hold off;

% end of the script=============================================================================================================
% ==============================================================================================================================
fclose(f);