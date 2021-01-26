% This notebook is to build a noise array and denoise it. The peaks will be
% used to measure a threhold.
n = 2; %<============== set noise frequency
scanrate = 15.5;  %<============== set scanrate
noiseLength = 15;  %<=========== set test minutes
blockunit = 0.005;  %<========= block distance unit. m/s

noise = zeros(1, noiseLength*60*scanrate);
spaceidx = round(linspace(1,length(noise), noiseLength*60*n*2+1));
flag = 1;
for i = 2:length(spaceidx)
    noise(randi([spaceidx(i-1), spaceidx(i)],1)) = flag * scanrate * blockunit;
    flag = flag * -1;
end
plot(noise);

% Gaussian filter====
gaussWidth = 1;
gaussSigma = 0.26;
gaussFilt = MakeGaussFilt( gaussWidth, 0, gaussSigma, scanrate );
noise_filtered = filtfilt( gaussFilt, 1, noise);
noise_filtered_bint_abs = abs(bint1D(noise_filtered, floor(scanrate)));
noise_filtered_abs_bint = bint1D(abs(noise_filtered), floor(scanrate));
subplot(2,1,1)
plot(noise);
hold on
plot(noise_filtered);
hold off
legend({'noise', 'filtered noise'});
ylabel('speed (m/s)');
xlabel('time course (min)');
xticks([0:scanrate*60*5:length(noise)]);
xticklabels([0:5:length(noise)/60]);
title('Set threshold of running speed');

subplot(2,1,2)
plot(noise_filtered_bint_abs);
hold on
plot(noise_filtered_abs_bint);
hold off
legend({'absolute after bint','bint after absolute'} );
ylabel('speed (m/s)');
xlabel('time course (min)');
xticks([0:60*5:length(noise_filtered_bint_abs)]);
xticklabels([0:5:length(noise_filtered_bint_abs)/60]);
title('Set threshold of running speed');

% measure threshold by calculate 99 quantile of the peaks ==========
testarray = noise_filtered_abs_bint;
noisepeak = diff(testarray); %<===== choose which array

noisepeakidx1 = find(noisepeak > 0);
noisepeakidx2 = find(noisepeak < 0) - 1;
noisepeakidx = intersect(noisepeakidx1, noisepeakidx2)+1;
threshold = pctl(testarray(noisepeakidx), 99);
sprintf('threshold: %s', threshold)
plot(testarray);
hold on
yline(threshold, '-.r');
hold off
ylim([0,1.5*threshold]);
lgd = legend({'noise', 'threshold'}, 'location', 'north');
legend('boxoff');
lgd.NumColumns = 2;
ylabel('speed (m/s)');
xlabel('time course (min)');
xticks([0:60*5:length(testarray)]);
xticklabels([0:5:length(testarray)/60]);
title('Set threshold of running speed');