function ref = ref_from_self(mx, parameters)

gap = 4;
registerPmt = parameters.config.registerPmt + 1;
outputpath = [parameters.refname];

f = size(mx, 4);
meanidx = 1:gap:f;
ref = uint16(mean(mx(:,:,registerPmt,meanidx), 4));

imwrite(ref, outputpath, 'tiff');

end