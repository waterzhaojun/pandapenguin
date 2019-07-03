function tif = loadTifStack(path)

    fileName = path;
    tiffInfo = imfinfo(fileName);  %# Get the TIFF file information
    tif = zeros(tiffInfo(1).Height, tiffInfo(1).Width, length(tiffInfo));    %# Preallocate the cell array
    for iFrame = 1:length(tiffInfo)
        tif(:,:,iFrame) = imread(fileName,'Index',iFrame,'Info',tiffInfo);
    end

end