load('C:\2pdata\CGRP0720\210224_CGRP0720\210224_CGRP0720_run10\running\result.mat')
runori = result.array;
runtreat = result.array_treated;
plot(runori)
plot(runtreat)
load('C:\2pdata\CGRP0720\210224_CGRP0720\210224_CGRP0720_run10\bv\1\result.mat')
bv = zeros(4,10000);
bv(1,:) = result.roi{1}.diameter;
bv(2,:) = result.roi{2}.diameter;
bv(3,:) = result.roi{3}.diameter;
bv(4,:) = result.roi{4}.diameter;
plot(bv');