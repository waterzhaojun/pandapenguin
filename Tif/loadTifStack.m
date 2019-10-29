 function FinalImage = loadTifStack(path)
    % need to edit to load color image.
    InfoImage = imfinfo(path);  %# Get the TIFF file information
    mImage = InfoImage(1).Width;
    nImage = InfoImage(1).Height;
    NumberImages = length(InfoImage);
    %nChannel = InfoImage(1).SamplesPerPixel;
    FinalImage = zeros(nImage, mImage, NumberImages, 'uint16');
    
    FileID = tifflib('open', path, 'r');
    rps = tifflib('getField', FileID, Tiff.TagID.RowsPerStrip);
    for i = 1:NumberImages
        tifflib('setDirectory', FileID, i);
        rps = min(rps, nImage);
        for r = 1:rps:nImage
            row_inds = r:min(nImage, r+rps-1);
            stripNum = tifflib('computeStrip', FileID, r);
            FinalImage(row_inds, :, i) = tifflib('readEncodedStrip', FileID, stripNum);
        end
    end
    tifflib('close', FileID);
end