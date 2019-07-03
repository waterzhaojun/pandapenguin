function avg = xyAvgValue(picMatrix, xy)
    
    len = size(xy, 1);
    avg = zeros(len, 1);
    for i = 1:len
        avg(i) = picMatrix(xy(i,1), xy(i,2));
    end
    avg = mean(avg);
    
end