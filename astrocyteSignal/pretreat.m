function pretreat(animalID, dateID, run, pmt, outputtif_avg_of_n_frams)
    
    % default scanrate = 15.5
    raw_data_scanrate = 15.5;
    
    outputpath = sbxDir(animalID, dateID, run);
    outputpath = outputpath.runs;
    outputpath = [outputpath{1}.path, animalID, '_', dateID, '_', num2str(run), '_pretreated_', num2str(round(outputtif_avg_of_n_frams/raw_data_scanrate)), 'Hz.tif'];
    
    mx = mxFromSbx(animalID, dateID, run, pmt);
    
    
    % In the whole pretreat. I think the most important steps are denoise
    % and registration. So far I didn't add registration inside as for
    % anesthesized rat the movie dosen't that much. But may need to add in
    % the future.
    mx1 = denoise(mx);
    
    mx1 = trimMatrix(animalID, dateID, run, mx1, 0); %if no extra frame, do not skip any frame here, set to 0.
    mx1 = downsample(mx1); % compress to 1/2 height and width size
    
    % outputtif_avg_of_n_frams = 45;
    
    
    mx2tif(mx1, outputpath, outputtif_avg_of_n_frams);

end