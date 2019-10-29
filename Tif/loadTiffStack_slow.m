function mx = loadTiffStack_slow(path)


info = imfinfo(path);
r = getfield(info, 'Height');
c = getfield(info, 'Width');
ch = getfield(info, 'SamplesPerPixel');
f = numel(info);

mx = zeros(r,c,ch,f);

for k = 1:f
    mx(:,:,:,k) = imread(path, k, 'Info', info);
end


end