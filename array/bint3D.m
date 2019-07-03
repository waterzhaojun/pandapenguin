function result = bint3D(matrix, binsize)
    % shrink 3rd dimension
    if nargin<2, binsize = 5; end

    [r,c,d] = size(matrix);
    result = reshape(matrix, [r, c, binsize, floor(d/binsize)]);
    result = squeeze(mean(result, 3));