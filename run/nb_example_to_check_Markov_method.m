scanrate = 15.5
animal = 'WT0118';
date = '201123';
run = 1;

array = signalarray;
array = a;

plot(array)
ylabel('speed (m/s)');
xlabel('time course (min)');
xticks([0:scanrate*60*5:length(array)]);
xticklabels([0:5:length(array)/scanrate/60]);
title('Original speed array');


gaussWidth = 1;
gaussSigma = 0.26;
gaussFilt = MakeGaussFilt( gaussWidth, 0, gaussSigma, scanrate );
array_filtered = filtfilt( gaussFilt, 1, array ); 
plot(array_filtered)
ylabel('speed (m/s)');
xlabel('time course (min)');
xticks([0:scanrate*60*5:length(array_filtered)]);
xticklabels([0:5:length(array_filtered)/scanrate/60]);
title('Low pass filtered speed array');

array_filtered_bintAb = abs(bint1D(array_filtered, floor(scanrate)));
plot(array_filtered_bintAb)
ylabel('speed (m/s)');
xlabel('time course (min)');
xticks([0:60*5:length(array_filtered_bintAb)]);
xticklabels([0:5:length(array_filtered_bintAb)/60]);
title('Low pass filtered speed array after bint and abs');

n = 1; %<=============================== set noise rate, based on this, we set threshold = 0.4
noise = zeros(1, 15*60*scanrate);
for i = 1:15*60/2
    a = zeros(1,scanrate*2/n);
    a(randi([1 floor(length(a)/2)],1)) = 1 * scanrate * cfg.blockunit;
    a(randi([floor(length(a)/2) + 1, length(a)],1)) = -1 * scanrate * cfg.blockunit;
    noise((i-1)*scanrate+1 : (i+1)*scanrate) = tmp;

a = repmat(a, 1, 15*60*scanrate/length(a));
noise = filtfilt( gaussFilt, 1, a);
noise = abs(bint1D(noise, floor(scanrate)));
disp(max(noise(floor(length(noise)*0.05) : floor(length(noise)*0.95))));
plot(noise);

array_filtered_bintAb2 = array_filtered_bintAb;
array_filtered_bintAb2(array_filtered_bintAb2 < 0.004) = 0;
plot(array_filtered_bintAb2)
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