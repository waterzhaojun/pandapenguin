function mx = connect_multi_pretreated_mov(animal, date, runs)

for i = 1:length(runs)
    path = sbxDir(animal, date, runs(i));
    if i == 1
        mx = loadTiffStack_slow(path.runs{1}.pretreatedmov);
        len = ndims(mx);
        disp(size(mx));
    else
        tmp = loadTiffStack_slow(path.runs{1}.pretreatedmov);
        mx = cat(len, mx, tmp);
        disp(size(tmp));
    end
    
end

mx = uint16(mx);
    
    
end