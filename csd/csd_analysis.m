function csd_analysis(csd_ana_setting_path, output_folderpath)

p = anaSettingAdapter(csd_ana_setting_path);
length_list = [];
for i = 1:length(p.runs)
    tmp = sbxDir(p.animal, p.date, p.runs(i));
    length_list(i) = numel(imfinfo(tmp.runs{1}.pretreatedmov));
end
mx = connect_multi_pretreated_mov(p.animal, p.date, p.runs);
brightness_array = squeeze(mean(mx, [1,2]));

csdmx = mxFromSbx(load_parameters(p.animal, p.date, p.csd_run));
csdmx = trimMatrix(csdmx, load_parameters(p.animal, p.date, p.csd_run));

[duration, tidycsdmx, tidypeakpoint] = process(csdmx, p);
speed = p.viewWidth * p.scanrate/ duration;

peakidx = 0
for i = 1:length(p.runs)
    if p.csd_run ~= p.runs(i)
        peakidx = peakidx + length_list(i);
    else
        peakidx = peakidx + ceil(tidypeakpoint/floor(p.scanrate));
        break
    end
end

if ~exist(output_folderpath, 'dir')
    mkdir(output_folderpath);
end
mx2tif(mx, [output_folderpath, 'wholeMov.tif']);
mx2tif(tidycsdmx, [output_folderpath, 'csdMov.tif']);
save([output_folderpath, 'result.mat'], 'brightness_array', 'speed', 'peakidx');
copyfile(csd_ana_setting_path, output_folderpath);

end

function p = anaSettingAdapter(path)

p = ReadYaml(path);
p.date = num2str(p.date);
p.runs = cell2mat(p.runs);

% suppose all runs have the same scan rate. If not, have to come back here
% change this parameter to an array
thepath = sbxPath(p.animal, p.date, p.runs(1), 'sbx'); 

tmp = sbxDir(p.animal, p.date, p.runs(1));
imginfo = imfinfo(tmp.runs{1}.pretreatedmov);

configinfo = ReadYaml(tmp.runs{1}.config);

inf = sbxInfo(thepath, true);
scanmode = [15.5, 31];
p.scanrate = scanmode(inf.scanmode);
p.viewWidth = inf.calibration(inf.config.magnification).x * getfield(imginfo, 'Width') * configinfo.downsample_size;

end

function [duration, csdmx, peakpoint] = process(mx, p)

pre_peak_duration = floor(p.scanrate * p.pre_peak_duration);
post_peak_duration = floor(p.scanrate * p.post_peak_duration);

csdtrend = squeeze(mean(mx, [1,2]));
horizen_avg = squeeze(mean(mx, [1]));
[m, peakpoint] = max(csdtrend);
% csdtrend = csdtrend(peakpoint-pre_peak_duration : peakpoint+ post_peak_duration);
start_line_trend = smooth(squeeze(horizen_avg(1, peakpoint-pre_peak_duration : peakpoint+ post_peak_duration)), 5);
end_line_trend = smooth(squeeze(horizen_avg(end, peakpoint-pre_peak_duration : peakpoint+ post_peak_duration)), 5);

t0 = csd_start_point(start_line_trend);
t1 = csd_end_point(end_line_trend);

duration = t1 - t0;
csdmx = mx(:,:,peakpoint-pre_peak_duration+t0:peakpoint-pre_peak_duration+t1);

end

function a = normarray(array)

ma = max(array);
mi = min(array);
a = (array-mi)/(ma-mi)+1;

end

function startpoint = csd_start_point(array)

    idx = kmeans(array, 2);
    a1 = mean(array(idx == 1));
    a2 = mean(array(idx == 2));
    baseline = min([a1, a2]);
    startpoint = find(array > baseline*1.2);
    startpoint = startpoint(1);


end

function startpoint = csd_end_point(array)

    idx = kmeans(array, 2);
    a1 = mean(array(idx == 1));
    a2 = mean(array(idx == 2));
    baseline = max([a1, a2]);
    startpoint = find(array > baseline*0.9);
    startpoint = startpoint(1);


end