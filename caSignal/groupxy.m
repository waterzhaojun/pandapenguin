function groups = groupxy(xyvector)
    
    groups = cell(1);
    remains = xyvector;
    
    for i = 1:size(xyvector, 1)
        groups{i} = remains(1,:);
        nextRemains = [];
        for j = 2:size(remains, 1)
            if isClose(remains(j,:), groups{i})
                groups{i} = [groups{i}; remains(j,:)];
            else
                nextRemains = [nextRemains; remains(j,:)];
            end
        end
        
        if size(nextRemains,1)==0
            break
        else
            remains = nextRemains;
        end
        
    end

end