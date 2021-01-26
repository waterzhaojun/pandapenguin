% This notebook is to test Markov method.

scanrate = 15.5
animal = 'WT0118';
date = '201123';
run = 1;

scanrate = 15.5
path = 'C:\Users\jzhao1\Downloads\WT0118_201123_000_quadrature.mat';
array = getRunningArray(path)*scanrate*0.005

plot(array)
ylabel('speed (m/s)');
xlabel('time course (min)');
xticks([0:scanrate*60*5:length(array)]);
xticklabels([0:5:length(array)/scanrate/60]);
title('Original speed array');

pctl = @(v,p) interp1(linspace(0.5/length(v), 1-0.5/length(v), length(v))', sort(v), p*0.01, 'spline');

gaussWidth = 1;
gaussSigma = 0.26;
gaussFilt = MakeGaussFilt( gaussWidth, 0, gaussSigma, scanrate );
array_filtered = filtfilt( gaussFilt, 1, array ); 
plot(array_filtered)
ylabel('speed (m/s)');
xlabel('time course (min)');
xticks([0:scanrate*60*5:length(array_filtered)]);
xticklabels([0:5:length(array_filtered)/scanrate/60]);
title('Gaussian filter filtered speed array');

array_filtered_bintAb = abs(bint1D(array_filtered, floor(scanrate)));
plot(array_filtered_bintAb)
ylabel('speed (m/s)');
xlabel('time course (min)');
xticks([0:60*5:length(array_filtered_bintAb)]);
xticklabels([0:5:length(array_filtered_bintAb)/60]);
title('Gaussian filter filtered speed array after bint and abs');

n = 1; %<=============================== set noise rate, based on this, we set threshold = 0.4
noise = zeros(1, 15*60*scanrate);
noiseLength = 15
for i = 1:noiseLength*60/2
    a = zeros(1,scanrate*2/n);
    a(randi([1 floor(length(a)/2)],1)) = 1 * scanrate * cfg.blockunit;
    a(randi([floor(length(a)/2) + 1, length(a)],1)) = -1 * scanrate * cfg.blockunit;
    noise((2*i-2)*scanrate+1 : 2*i*scanrate) = a;
end
noise = filtfilt( gaussFilt, 1, noise);
noise = abs(bint1D(noise, floor(scanrate)));
noisepeak = diff(noise);
noisepeakidx1 = find(noisepeak > 0);
noisepeakidx2 = find(noisepeak < 0) - 1;
noisepeakidx = intersect(noisepeakidx1, noisepeakidx2);
noisepeak = noisepeak(noisepeakidx);
threshold = pctl(noisepeak, 99);
disp(max(noise(floor(length(noise)*0.05) : floor(length(noise)*0.95))));
plot(noise);

array_filtered_bintAb2 = array_filtered_bintAb;
array_filtered_bintAb2(find(array_filtered_bintAb2 < threshold)) = 0;
plot(array_filtered_bintAb);
hold on
plot(array_filtered_bintAb2);
hold off
ylabel('speed (m/s)');
xlabel('time course (min)');
xticks([0:60*5:length(array_filtered_bintAb2)]);
xticklabels([0:5:length(array_filtered_bintAb2)/60]);
title('Set threshold of running speed');

tmp = bint1D(abs(array), 15);
plot(tmp);
hold on
plot(array_filtered_bintAb);
plot(state * 0.01);
hold off