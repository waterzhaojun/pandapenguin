function writetiffJun(mx, path)
    % this function is for 3D matrix
    for(i = 1:size(mx,3))
        
        imwrite(mx(:,:,i), path, ...
                'WriteMode', 'append');
        
    end

end