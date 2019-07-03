function maxFiberMap(array, path)
    
    maxMt = getMaxMatrix(array);
    maxMt = im2uint8(uint16(maxMt));
    
    maxMt = imadjust(maxMt);
    
    imwrite(maxMt, [path, 'fiberMap.tif']);
    
end