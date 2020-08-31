function csd_analysis(animal, date, run, pmt, csdrun, csd_ana_setting_path, output_folderpath)
% At 8/20/2020, I can't remember which function i used to analyze CSD
% trial. But this one seems not the correct one. I believe the correct one
% is csd_single_trial_analysis.m
% I will mark this one as deprecated file.

% analysis csd trial
csdp = load_parameters(animal, date, csdrun, pmt);
csdmx = load(csdp.registration_mx_path);
csdmx = csdmx.registed_mx;
csd_reg_p = load(csdp.registration_parameter_path);
csdmx_cropped = dft_clean_edge(csdmx, csd_reg_p.shift + csd_reg_p.superShife);
csdarray = get_csd_array(csdmx_cropped);
character = csd_character(csdarray);

% analysis A1
tmpmx = uint16(csdmx(:,:,csdp.pmt+1,1:character.csd_start_point));
tmpmx = dft_clean_edge(tmpmx, csd_reg_p.shift(1:character.csd_start_point, :), ...
    + csd_reg_p.superShife(1:character.csd_start_point, :));
tmpp = csdp;
tmpmx = downsample(tmpmx, tmpp);
tmpp.pretreated_mov = [csdp.basicname, '_csd_A1_mov.tif'];
tmpp.run = [num2str(csdp.run), '_csdA1'];
mx2tif(tmpmx, tmpp.pretreated_mov);
analysis_aqua(tmpp);

% analysis C
tmpmx = uint16(csdmx(:,:,csdp.pmt+1, character.csd_start_point:character.csd_end_point));
tmpmx = dft_clean_edge(tmpmx, csd_reg_p.shift(character.csd_start_point:character.csd_end_point, :)...
    + csd_reg_p.superShife(character.csd_start_point:character.csd_end_point, :));
tmpp = csdp;
tmpmx = downsample(tmpmx, tmpp);
tmpp.pretreated_mov = [csdp.basicname, '_csd_C_mov.tif'];
tmpp.run = [num2str(csdp.run), '_csdC'];
mx2tif(tmpmx, tmpp.pretreated_mov);
tmpp.config.related_setting_file.aqua_parameter_file = 'D:\\Jun\\pandapenguin\\astrocyteSignal\\aqua_csd_parameters.yml';
analysis_aqua(tmpp);

% analysis A2
tmpmx = uint16(csdmx(:,:,csdp.pmt+1, character.csd_end_point:character.a2_endpoint));
tmpmx = dft_clean_edge(tmpmx, csd_reg_p.shift(character.csd_end_point:character.a2_endpoint, :)...
    + csd_reg_p.superShife(character.csd_end_point:character.a2_endpoint, :));
tmpp = csdp;
tmpmx = downsample(tmpmx, tmpp);
tmpp.pretreated_mov = [csdp.basicname, '_csd_A2_mov.tif'];
tmpp.run = [num2str(csdp.run), '_csdA2'];
mx2tif(tmpmx, tmpp.pretreated_mov);
analysis_aqua(tmpp);

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

function a=get_csd_array(mx)

mx= normalize(double(mx), 4);
a = squeeze(mean(mx, [1,2]));

end