
% sbxPath = 'C:\2pdata\DL175\191211_DL175\191211_DL175_run1\DL175_191211_000.sbx';
% refPath = 'C:\2pdata\DL175\191211_DL175\191211_DL175_run1\ref.tif';

animal = 'WT0118';
date = '201123';
run = 1;
pmt = 0;

sbxPath = 'C:\2pdata\WT0118\201123_WT0118\201123_WT0118_run1\WT0118_201123_000.sbx';
refPath = 'C:\2pdata\WT0118\201123_WT0118\201123_WT0118_run1\WT0118_201123_000_registration_ref.tif';
AffineAlignPlanes(sbxPath, refPath);



projPath = 'C:\2pdata\WT01\201111_WT01\201111_WT01_run3\test.tif';
refPath = 'C:\2pdata\CGRP03\201109_CGRP03\201109_CGRP03_run1\CGRP03_201109_000_greenChl_3Dstructure.tif';
refChan = 2;
refScan = [];
scaleFactor = 2;
overwrite = true;
minInt = 2000;
edges = [];

WriteSbxProjection(sbxPath, infoStruct, projPath);

javaaddpath 'C:\Program Files\MATLAB\R2020b\java\mij.jar';
javaaddpath 'C:\Program Files\MATLAB\R2020b\java\ij-1.51s.jar';  %<---- Jun: This is the imageJ used in 2P computer
javaaddpath 'C:\Program Files\MATLAB\R2020b\java\TurboRegHL_.jar';
MIJ.start('C:\Users\Levylab\Desktop\Fiji.app');

build_registration_ref_vnew(animal, date, run, pmt);
infoStruct = pipe.io.sbxInfo(sbxPath, true);
AffineAlignPlanes(sbxPath, refPath);

expt = struct();
expt.animal = 'CGRP03';
expt.date = '201109';
expt.Nruns = [1];
sbxPath = 'C:\2pdata\CGRP03\201109_CGRP03\201109_CGRP03_run1\CGRP03_201109_000.sbx';
infoStruct = pipe.io.sbxInfo(sbxPath, true);
[a,b] = GetDeformCat3D( expt, infoStruct);



animal = 'CGRP03';
date = '201109';
run = 3;
running_analysis(animal, date, run);
rundata = extractRunningData(animal, date, run);
bvdata = extractBvData(animal, date, run);
runningCorrelationPlot(rundata, {bvdata}, {{'diameter'}}, {'layer'});


path = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ';
a = load_exp(path);
