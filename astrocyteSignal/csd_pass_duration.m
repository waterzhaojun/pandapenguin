function aa = csd_pass_duration(animalID, dateID, run, pmt)
    
   % raw_data_scanrate = 15.5;
    
    outputpath = sbxDir(animalID, dateID, run);
    outputpath = outputpath.runs;
    outputpath = [outputpath{1}.path, animalID, '_', dateID, '_', num2str(run), '_CSD.tif'];
    scanrate = 15.5;
    pre_peak_duration = floor(scanrate * 10);
    post_peak_duration = floor(scanrate * 5);
    
    mx = mxFromSbx(animalID, dateID, run, pmt);
    mx = trimMatrix(animalID, dateID, run, mx, 0);

    csdtrend = squeeze(mean(mx, [1,2]));
    horizen_avg = squeeze(mean(mx, [1]));
    [m, peakpoint] = max(csdtrend);
   % csdtrend = csdtrend(peakpoint-pre_peak_duration : peakpoint+ post_peak_duration);
    start_line_trend = smooth(squeeze(horizen_avg(1, peakpoint-pre_peak_duration : peakpoint+ post_peak_duration)), 5);
    end_line_trend = smooth(squeeze(horizen_avg(end, peakpoint-pre_peak_duration : peakpoint+ post_peak_duration)), 5);
   % [m, peakpoint] = max(csdtrend);
    
    t0 = csd_start_point(start_line_trend);
    t1 = csd_end_point(end_line_trend);
   
    aa = t1 - t0;
    
    mx2tif(mx(:,:,peakpoint-pre_peak_duration+t0:peakpoint-pre_peak_duration+t1), outputpath);
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