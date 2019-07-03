function v = arrayShrink(array, n)

    [nr, nc] = size(array);
    for i=1:floor(nr/n)
        for j = 1:floor(nc/n)
            v(i,j) = mean2(array((i-1)*n+1:i*n, (j-1)*n+1:j*n));
        end
    end
end