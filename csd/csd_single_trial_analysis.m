function csd_single_trial_analysis(p)

% calculate csd speed. This step need unregisted movie.
mx = mxFromSbx(p);
mx = denoise(mx, p);
mx = trimMatrix(mx, p);

foldername = [p.dirname, 'run', num2str(p.run), '_CSD\'];
if ~exist(foldername, 'dir')
    mkdir(foldername)
end

mx= normalize(double(mx), 4);
csdarray = squeeze(mean(mx, [1,2]));
character = csd_character(csdarray);

[duration, tidycsdmx] = process(mx(:,:,:,character.csd_start_point:character.csd_end_point), p);
speed = size(mx, 2) * p.scanrate/ duration;
mx2tif(tidycsdmx, [foldername, 'csdMov.tif']);
A1_duration = character.csd_start_point;
C_duration = character.csd_end_point - character.csd_start_point;
A2_duration = character.a2_endpoint - character.csd_end_point;
peakidx = character.peakidx;
csd_start_point = character.csd_start_point;
csd_end_point = character.csd_end_point;
A2_endpoint = character.a2_endpoint;
save([foldername, 'result.mat'], 'csdarray', 'speed', 'peakidx', ...
    'A1_duration', 'C_duration', 'A2_duration', 'csd_start_point',...
    'csd_end_point', 'A2_endpoint');


% If you did registration, you can anlyse the following part.
csdmx = load(p.registration_mx_path);
csdmx = csdmx.registed_mx;
csd_reg_p = load(p.registration_parameter_path);
% csdmx_cropped = dft_clean_edge(csdmx, csd_reg_p.shift + csd_reg_p.superShife);

% analysis A1
tmpmx = uint16(csdmx(:,:,p.pmt+1,1:csd_start_point));
tmpmx = dft_clean_edge(tmpmx, csd_reg_p.shift(1:csd_start_point, :), ...
    + csd_reg_p.superShife(1:csd_start_point, :));
tmpp = p;
tmpmx = downsample(tmpmx, tmpp);
tmpp.pretreated_mov = [p.basicname, '_csd_A1_mov.tif'];
tmpp.run = [num2str(p.run), '_csdA1'];
mx2tif(tmpmx, tmpp.pretreated_mov);
analysis_aqua(tmpp);
movefile(tmpp.pretreated_mov, foldername);
movefile([tmpp.dirname, 'run', tmpp.run, '_AQuA'], foldername);

% analysis C
tmpmx = uint16(csdmx(:,:,p.pmt+1, csd_start_point:csd_end_point));
tmpmx = dft_clean_edge(tmpmx, csd_reg_p.shift(csd_start_point:csd_end_point, :)...
    + csd_reg_p.superShife(csd_start_point:csd_end_point, :));
tmpp = p;
tmpmx = downsample(tmpmx, tmpp, 'shift', csd_reg_p.shift(csd_start_point:csd_end_point, :)...
    + csd_reg_p.superShife(csd_start_point:csd_end_point, :));
tmpmx = remove_blank_frame(tmpmx);
tmpp.pretreated_mov = [p.basicname, '_csd_C_mov.tif'];
tmpp.run = [num2str(p.run), '_csdC'];
mx2tif(tmpmx, tmpp.pretreated_mov);
tmpp.config.related_setting_file.aqua_parameter_file = 'D:\\Jun\\pandapenguin\\astrocyteSignal\\aqua_csd_parameters.yml';
analysis_aqua(tmpp);
movefile(tmpp.pretreated_mov, foldername);
movefile([tmpp.dirname, 'run', tmpp.run, '_AQuA'], foldername);

% analysis A2
tmpmx = uint16(csdmx(:,:,p.pmt+1, csd_end_point:A2_endpoint));
tmpmx = dft_clean_edge(tmpmx, csd_reg_p.shift(csd_end_point:A2_endpoint, :)...
    + csd_reg_p.superShife(csd_end_point:A2_endpoint, :));
tmpp = p;
tmpmx = downsample(tmpmx, tmpp);
tmpp.pretreated_mov = [p.basicname, '_csd_A2_mov.tif'];
tmpp.run = [num2str(p.run), '_csdA2'];
mx2tif(tmpmx, tmpp.pretreated_mov);
analysis_aqua(tmpp);
movefile(tmpp.pretreated_mov, foldername);
movefile([tmpp.dirname, 'run', tmpp.run, '_AQuA'], foldername);

%==============================================================
% p = anaSettingAdapter(csd_ana_setting_path); don't need to use this yml
% any more


% copyfile(csd_ana_setting_path, output_folderpath);

end


function [duration, csdmx] = process(csdpartmx, p)

horizen_avg = squeeze(mean(csdpartmx, [1]));
% [m, peakpoint] = max(csdtrend);
% csdtrend = csdtrend(peakpoint-pre_peak_duration : peakpoint+ post_peak_duration);
start_line_trend = smooth(squeeze(horizen_avg(1, :)), 5);
end_line_trend = smooth(squeeze(horizen_avg(end, :)), 5);

t0 = csd_start_point(start_line_trend, 's');
t1 = csd_start_point(end_line_trend, 's');

duration = t1 - t0+1;
csdmx = csdpartmx(:,:,t0:t1);

end

function a = normarray(array)

ma = max(array);
mi = min(array);
a = (array-mi)/(ma-mi)+1;

end


function startpoint = csd_start_point(array, point)
    
    array = array(2:end)-array(1:end-1);
    idx = kmeans(array, 2);
    a1 = mean(array(idx == 1));
    a2 = mean(array(idx == 2));
    [baseline,idnum] = max([a1, a2]);
    % startpoint = find(array > baseline*1.2);
    starts = find(idx == idnum);
    if strcmp(point, 's')
        startpoint = starts(1);
    elseif strcmp(point, 'e')
        startpoint = starts(end);
    end


end



function newmx = remove_blank_frame(mx)

[r,c,ch,f] = size(mx);
if ch > 1
    error('This only support 1 channel mx');
end
s = squeeze(sum(mx, [1,2]));

fs = find(s == 0);

mx(:,:,:,fs) = [];

newmx = mx;

end