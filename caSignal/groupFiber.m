function [groupArea, groupValue]=groupFiber(array, xy, distance)
% This is the core function to make calcium value.
    % set some parameter
    coefThreshold = 0.5;
    keepPercent = 0.04;
    keepNumber = 50;
    if nargin < 3, distance = 4; end
    
    border = fiberBorder(xy, distance);
    groupArea{1} = xy(1,:);
    groupValue{1} = double(reshape(array(xy(1,1), xy(1,2), :), [],1));
        
    for i = 2:size(xy, 1)
        around = aroundPoints(xy(i,1), xy(i,2), distance);
        around = intersect(around, border, 'rows');
        obj = double(reshape(array(xy(i,1),xy(i,2),:), [],1) - xy3DValue(array, around));
        cangroup = 0;
        for j = 1:size(groupValue, 1)
            corr = corrcoef(obj, groupValue{j});
            corr = corr(1,2);
            if corr > coefThreshold
                groupArea{j} = [groupArea{j};xy(i,:)];
                groupValue{j} = groupValue{j} + (obj - groupValue{j})/size(groupArea{j}, 1); 
                cangroup = 1;
                break;
            end
        end
        if cangroup == 0
            n = size(groupValue,2)+1;
            groupArea = [groupArea; xy(i,:)];
            groupValue = [groupValue; obj];
        end
        if rem(i, floor(size(xy,1)/100)) == 0
            disp(sprintf('%d%% points have been grouped', i/floor(size(xy,1)/100)));
        end
    end
    
    % for those group has less points, just delete them
    for i = 1:size(groupArea,1)
        if size(groupArea{i}, 1) < max(round(size(groupArea, 1)*keepPercent), keepNumber)
            groupArea{i} = [];
            groupValue{i} = [];
        end
               
    end
    groupArea(cellfun('isempty',groupArea)) = [];
    groupValue(cellfun('isempty',groupValue)) = [];
    
    for i = 1:size(groupValue, 1)
        groupValue{i} = uint16(groupValue{i});
    end

end
