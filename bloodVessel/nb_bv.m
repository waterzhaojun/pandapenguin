%% single trial analysis steps
list = {
    'CGRP01','201118',1;'CGRP01','201118',2;...
    
    'CGRP02','201110',2;'CGRP02','201110',3;...
    'CGRP02','201117',1;'CGRP02','201117',2;'CGRP02','201117',3;'CGRP02','201117',4;...
    'CGRP02','201119',1;'CGRP02','201119',2;'CGRP02','201119',3;...
    
    'CGRP03','201109',1;'CGRP03','201109',2;...
    'CGRP03','201116',1;'CGRP03','201116',2;'CGRP03','201116',3;'CGRP03','201116',4;'CGRP03','201116',5;'CGRP03','201116',6;...
    'CGRP03','201118',1;'CGRP03','201118',2;'CGRP03','201118',3;'CGRP03','201118',4;'CGRP03','201118',5;'CGRP03','201118',6;'CGRP03','201118',7;...
    'CGRP03','201120',1;...
    
    'WT01','201111',1;'WT01','201111',2;'WT01','201111',3;'WT01','201111',4;...
    'WT01','201117',1;'WT01','201117',2;'WT01','201117',3;'WT01','201117',4;'WT01','201117',5;'WT01','201117',6;...
    'WT01','201119',1;'WT01','201119',2;'WT01','201119',3;'WT01','201119',4;'WT01','201119',5;...
    'WT01','201124',1;'WT01','201124',2;'WT01','201124',3;'WT01','201124',4;...
    'WT01','201125',1;'WT01','201125',2;...
    }

for st = 10:size(list,1)
    root = sbxDir(list{st,1}, list{st,2},list{st,3});
    info = load([root.runs{1}.base, '.mat']);
    info = info.info;
    root = root.runs{1}.path;
    disp(list{st,1});
    disp(list{st,2});
    disp(list{st,3});
    if info.scanmode == 1
        tmpscanrate = 15;
    elseif info.scanmode == 2
        tmpscanrate = 31;
    end
    if length(inf.otparam) == 3
        tmplayers = inf.otparam(3);
    else
        tmplayers = 1; % if it is single layer, set z to 1.
    end
    bvroot = [root, 'bv\'];
    bvsub = dir(bvroot);
    bvsub = bvsub(~ismember({bvsub.name},{'.','..'}));
    for i = 1:length(bvsub)
        result = load([bvsub(i).folder, '\',bvsub(i).name,'\result.mat']);
        result = result.result;
        result.scanrate = tmpscanrate / tmplayers;
        save([bvsub(i).folder, '\',bvsub(i).name,'\result.mat'], 'result');
        
    end
end


%% cross trial analysis steps
source = {}
outputfolder = 