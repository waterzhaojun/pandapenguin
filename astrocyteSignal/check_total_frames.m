function check_total_frames(animalID, dateID, run)

    path = sbxPath(animalID, dateID, run, 'sbx'); 
    
    inf = sbxInfo(path, true);

    x = inf.max_idx+1;
    
    % default_scan_rate = 15.5
    
    disp(['total frames: ', num2str(x)]);%/default_scan_rate




end