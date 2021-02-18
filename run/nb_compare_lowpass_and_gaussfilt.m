array = repmat([1,1],1,1000);
array_lowpass = lowpass(array, 1, 15);
array_gaussfilt = gaussfilt(1:length(array), array, std(array));
% plot(array)
% hold on
plot(array_lowpass)
hold on
plot(array_gaussfilt)
hold off