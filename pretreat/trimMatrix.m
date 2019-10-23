function output = trimMatrix(mx, parameters)

    %animalID = parameters.animal;
    %dateID = parameters.date;
    %run = parameters.run;
    
    %path = sbxPath(animalID, dateID, run, 'sbx'); 
    edges = parameters.config.edge;
    edges = cell2mat(edges);
    % disp(edges);
    
    if ndims(mx)==4
        output = mx(edges(3)+1:end-edges(4), edges(1)+1:end-edges(2), :,...
            parameters.keep_frames_start:parameters.keep_frames_start+parameters.keep_frames-1);
        
    elseif ndims(mx)==3
        output = mx(edges(3)+1:end-edges(4), edges(1)+1:end-edges(2), ...
            parameters.keep_frames_start:parameters.keep_frames_start+parameters.keep_frames-1);
    
    elseif ndims(mx)==2
        output = mx(edges(3)+1:end-edges(4), edges(1)+1:end-edges(2));
    end
end