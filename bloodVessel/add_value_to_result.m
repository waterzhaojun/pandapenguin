function add_value_to_result(animalID, dateID, run, bvid, para, value)
    
    bvpath = sbxDir(animalID, dateID, run); 
    bvpath = [bvpath.runs{1}.path, 'bv_', num2str(bvid), '\', 'result.mat'];
    
    if strcmp(para, 'vessel_type')
        vessel_type = value;
        save(bvpath, 'vessel_type', '-append');
    elseif strcmp(para, 'tissue')
        tissue = value;
        save(bvpath, 'tissue', '-append');
    else
        disp('do not know this parameter');
    end


end