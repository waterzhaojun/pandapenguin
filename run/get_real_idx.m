function idx = get_real_idx(array, idxsec, scanrate, standard, tail)

idx0 = (idxsec-2)*floor(scanrate)+1;
idx1 = (idxsec-1)*floor(scanrate)+1;
idx2 = idxsec*floor(scanrate);
idx3 = (idxsec+1)*floor(scanrate);
disp(idx0)
disp(idx1)
disp(idx2)
disp(idx3)

if strcmp(tail, 'start')
    tmparray = array(idx1:idx2);
    disp(tmparray)
    idx = find(tmparray > standard);
    disp(idx)
    idx = idx(1);
    disp(idx);
    if idx > 1
        idx = idx1 + idx - 1;
    else
        backuparray = array(idx0:idx1-1);
        disp(backuparray)
        tmp = find(backuparray < standard);
        disp(tmp)
        idx = idx1 - tmp(end);
    end
elseif strcmp(tail, 'end')
    tmparray = array(idx1:idx2);
    idx = find(tmparray > standard);
    idx = idx(end);
    if idx < length(tmparray)
        idx = idx1 + idx -1;
    else
        backuparray = array(idx2+1:idx3);
        tmp = find(backuparray < standard);
        idx = idx2 + tmp(1) - 1;
    end
end

end