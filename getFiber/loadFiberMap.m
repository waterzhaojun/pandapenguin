function map = loadFiberMap(path)
    pic = imread(path);
    if strcmp(class(pic), 'uint16')
        maxN = 65535;
    elseif strcmp(class(pic), 'uint8')
        maxN = 255;
    end
    [rinx, cinx] = find(pic > maxN*0.7);
    map = [rinx, cinx];
end