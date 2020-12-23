%%% blood vessel wheel running correlation notebook
%
%
%
%
%% Information
%
animal = 'WT01';
date = '201111';
run = 1;

prebout = 3; % unit is sec
postbout = 10; % unit is sec

bvfilesys = bv_file_system();

runpath = sbxPath(animal, date, run, 'running');
runpath = runpath.result;
runresult = load(runpath);
runresult = runresult.result;
%
%%
df = correlation_table_running_bv({animal, date, run;});
files = unique({df.bvresultfile});
disp(files);

%% choose the subfolder you want to check
i = 1;
resfile = files{i};
result = load(resfile);
result = result.result;

ref = read(Tiff([correct_folderpath(fileparts(files{i})), bvfilesys.refpath],'r'));

scanrate = result.scanrate;
prelength = scanrate * prebout;
postlength = scanrate * postbout;

j = 1;

subdf = df([df.bvroiidx] == j);
diameter = result.roi{j}.diameter;
mask = result.roi{j}.BW;
mx = []; %plot 1hz timecourse 
for s = 1:length(subdf)
    startidx = subdf(s).bvstartidx;
    tmp = diameter(startidx - prelength:startidx + postlength-1);
    baseline = mean(tmp(1:prelength));
    tmp = (tmp - baseline)/baseline;
    tmp = bint(tmp, scanrate);
    tmp = reshape(tmp, 1,[]);
    if length(mx) == 0
        mx = tmp;
    else
        mx = cat(1, mx, tmp);
    end
    
    meantl = mean(mx,1);
    ste = std(mx,1)/sqrt(size(mx,1));
    
    subref = addroi(ref, mask);
end
subplot(2,2,1);
plot(mx');
subplot(2,2,2);
errorbar(meantl, ste);
subplot(2,2,3);
imshow(subref);
subplot(2,2,4);
plot_running(runresult);
hold on
plot(bint(diameter, scanrate));
hold off



