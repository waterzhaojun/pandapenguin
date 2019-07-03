function result = bint3D(matrix, binsize)
    % shrink columns

    [r,c,f] = size(matrix);
    result = reshape(matrix(:, :, 1:binsize*floor(f/binsize)), [r, c, binsize, floor(f/binsize)]);
    result = squeeze(mean(result, 3));