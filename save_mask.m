function save_mask(bw, xi, yi, tifpath)

parapath = strcat(tifpath(:-4), '_maskParameter.mat');
coord = [];
coord = find(bw == 1);