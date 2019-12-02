

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