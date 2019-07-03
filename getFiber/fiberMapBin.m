function fiber = fiberMapBin(animalID, dateID, run, minv, maxv)

    path = sbxDirJun(animalID, dateID, run);
    path = path.runs{1}.fiberMap;
    
    pic = imread(path);
    
    array = pic;
    array(array<minv | array>maxv) = 0;
    
    [nr,nc] = size(array);
    fiber = uint16(zeros(nr, nc));
    % background = uint16(zeros(nr, nc));
    
    for i = 3:(nr-2)
        for j = 1:nc
            if array(i,j) == max(array(i-2:i+2, j)) && array(i,j) ~= min(array(i-2:i+2, j))
                fiber(i,j) = 65535;
            end
        end
    end
    
    % background(pic<(minv/2)) = 65535;
    
    imwrite(fiber, [path(1:end-4), '_fiberBin.tif']);
    % imwrite(background, [path(1:end-4), '_bgBin.tif']
end


