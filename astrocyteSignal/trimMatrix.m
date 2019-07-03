function output = trimMatrix(animalID, dateID, run, mx, startSkip)
    path = sbxPath(animalID, dateID, run, 'sbx'); 
    edges = sbxRemoveEdges(path);
    disp(edges);
    output = mx(edges(3)+1:end-edges(4), edges(1)+1:end-edges(2), startSkip+1:end);
end