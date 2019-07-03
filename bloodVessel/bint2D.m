function result = bint2D(matrix, binsize)
    % shrink columns
    if nargin<2, binsize = 60; end

    [r,c] = size(matrix);
    result = reshape(matrix(:, 1:binsize*floor(c/binsize)), [r, binsize, floor(c/binsize)]);
    result = squeeze(mean(result, 2));