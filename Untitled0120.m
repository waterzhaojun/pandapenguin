
% sbxPath = 'C:\2pdata\DL175\191211_DL175\191211_DL175_run1\DL175_191211_000.sbx';
% refPath = 'C:\2pdata\DL175\191211_DL175\191211_DL175_run1\ref.tif';

animal = 'WT01';
date = '201111';
run = 3;
pmt = 0;

sbxPath = 'C:\2pdata\WT01\201111_WT01\201111_WT01_run3\WT01_201111_002.sbx';
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


infoStruct = pipe.io.sbxInfo(sbxPath, true);
AffineAlignPlanes(sbxPath, '');