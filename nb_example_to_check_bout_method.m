path='D:\2P\CGRP03\201109_CGRP03\201109_CGRP03_run4\CGRP03_201109_003_quadrature.mat';
cfg = run_config();
scanrate=cfg.scanrate;
bout_length_threshold = 5; %sec

% ori array
array = getRunningArray(path, 'deshake', false) * cfg.blockunit * scanrate;
plot(array)
ylabel('speed (m/s)');
xlabel('time course (min)');
xticks([0:scanrate*60*5:length(array)]);
xticklabels([0:5:length(array)/scanrate/60]);
title('Original speed array');

% low pass array
lowpass_array = lowpass(array, 1, scanrate);
plot(lowpass_array)
ylabel('speed (m/s)');
xlabel('time course (min)');
xticks([0:scanrate*60*5:length(lowpass_array)]);
xticklabels([0:5:length(lowpass_array)/scanrate/60]);
title('Low pass filtered speed array');

% abs acceleration array
ab_treat = abs(gradient(lowpass_array) * scanrate);
plot(ab_treat)
ylabel('acceleration (m/s2)');
xlabel('time course (min)');
xticks([0:scanrate*60*5:length(ab_treat)]);
xticklabels([0:5:length(ab_treat)/scanrate/60]);
title('Absolute value of acceleration array');

% noise array
n = 1; %<=============================== set noise rate
a = zeros(1,scanrate*2/n);
a(randi([1 floor(length(a)/2)],1)) = 1 * scanrate * cfg.blockunit;
a(randi([floor(length(a)/2) + 1, length(a)],1)) = -1 * scanrate * cfg.blockunit;
a = repmat(a, 1, 5*60*scanrate/length(a));
a = lowpass(a, 1, scanrate);
a = abs(gradient(a) * scanrate);
plot(a);
ylabel('acceleration (m/s2)');
xlabel('time course (min)');
xticks([0:scanrate*60:length(a)]);
xticklabels([0:1:length(a)/scanrate/60]);
title('Noise array after same pretreatment');
max(a)

% acceleration array with threshold, and show with identified bout. Using
% percentage in 1 sec to connect positive points.
threshold = 0.08;
binary_array = heaviside(ab_treat - threshold);
for i = 1:ceil(length(binary_array)/scanrate)
    tmpstart = (i-1)*scanrate + 1;
    tmpend = min(i*scanrate, length(binary_array));
    if sum(binary_array(tmpstart:tmpend))>=0.1*(tmpend - tmpstart + 1)
        binary_array(tmpstart:tmpend) = 1;
    end
end
bar(ab_treat, 'b')
hold on 
bar(binary_array * threshold, 'FaceColor',[1,1,0], 'FaceAlpha', 0.8, 'EdgeColor', 'none')
hold off
ylabel('acceleration (m/s2)');
xlabel('time course (min)');
xticks([0:scanrate*60*5:length(ab_treat)]);
xticklabels([0:5:length(ab_treat)/scanrate/60]);
title('Absolute value of acceleration array will gap filling');

search_array = ['0  ', num2str(binary_array), '  0'];
search_array = replace(search_array, '  ', '');
startidx = strfind(search_array, '01');
endidx = strfind(search_array, '10') - 1;
bout = struct();
boutidx = 0;
for i =1:length(startidx)
    if endidx(i) - startidx(i) >= scanrate * bout_length_threshold
        disp(endidx(i) - startidx(i));
        boutidx = boutidx + 1;
        bout(boutidx).startidx = startidx(i);
        bout(boutidx).endidx = endidx(i);
        bout(boutidx).array = ab_treat(startidx(i):endidx(i));
    end
end
bar(ab_treat, 'b')
hold on
yline(threshold);
for i = 1:length(bout)
    b = bar([bout(i).startidx:bout(i).endidx], repmat(threshold, 1, bout(i).endidx - bout(i).startidx + 1), 'FaceColor',[1,1,0], 'FaceAlpha', 0.8, 'EdgeColor', 'none');
    %b.FaceAlpha = 0.3;
end
hold off
ylabel('acceleration (m/s2)');
xlabel('time course (min)');
xticks([0:scanrate*60*5:length(ab_treat)]);
xticklabels([0:5:length(ab_treat)/scanrate/60]);
title('Absolute value of acceleration array and identified bout');

% acceleration array with threshold, and show with identified bout. Using
% gap threshold to connect positive points.
threshold = 0.08;
binary_array = heaviside(ab_treat - threshold);
binary_array = fillLogicHole(binary_array, scanrate);
bar(ab_treat, 'b')
hold on 
bar(binary_array * threshold, 'FaceColor',[1,1,0], 'FaceAlpha', 0.8, 'EdgeColor', 'none')
hold off
ylabel('acceleration (m/s2)');
xlabel('time course (min)');
xticks([0:scanrate*60*5:length(ab_treat)]);
xticklabels([0:5:length(ab_treat)/scanrate/60]);
title('Absolute value of acceleration array will gap filling');

search_array = ['0  ', num2str(binary_array), '  0'];
search_array = replace(search_array, '  ', '');
startidx = strfind(search_array, '01');
endidx = strfind(search_array, '10') - 1;
bout = struct();
boutidx = 0;
for i =1:length(startidx)
    if endidx(i) - startidx(i) >= scanrate * bout_length_threshold
        disp(endidx(i) - startidx(i));
        boutidx = boutidx + 1;
        bout(boutidx).startidx = startidx(i);
        bout(boutidx).endidx = endidx(i);
        bout(boutidx).array = ab_treat(startidx(i):endidx(i));
    end
end
bar(ab_treat, 'b')
hold on
yline(threshold);
for i = 1:length(bout)
    b = bar([bout(i).startidx:bout(i).endidx], repmat(threshold, 1, bout(i).endidx - bout(i).startidx + 1), 'FaceColor',[1,1,0], 'FaceAlpha', 0.8, 'EdgeColor', 'none');
    %b.FaceAlpha = 0.3;
end
hold off
ylabel('acceleration (m/s2)');
xlabel('time course (min)');
xticks([0:scanrate*60*5:length(ab_treat)]);
xticklabels([0:5:length(ab_treat)/scanrate/60]);
title('Absolute value of acceleration array and identified bout');

% binerize the acceleration array

