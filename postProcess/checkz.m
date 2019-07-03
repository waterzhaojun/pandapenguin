function outVe = checkz(array)
    
    [nr, nc, nf] = size(array);
    template = array(:,:,1);
    maxMt = zeros(nr, 2);
    for i = 1:nr
        maxMt(i,1) = i;
        r = find(template(i,:) == max(template(i,:)));
        maxMt(i,2) = r(1);
    end
    
    outVe = zeros(nf,1);
    for i = 1:nf
        outVe(i) = xyAvgValue(array(:,:,i), maxMt);
    end
    
end

