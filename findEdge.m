function diameter = findEdge(vector, span)
    
    % in case the image is dim, we need do smooth first. 
    if nargin<2
        span = 15;
    end
    vector = smooth(vector, span);
    
    baseline_left = min(vector(1:floor(end/2)));
    %baseline_left = mean(baseline_left(1:3));
    baseline_right = min(vector(floor(end/2):end));
    %baseline_right = mean(baseline_right(1:3));
    [peak_left, peak_left_idx] = max(vector(1:floor(end/2)));
    peak_left_idx = min(peak_left_idx);
    [peak_right, peak_right_idx] = max(vector(floor(end/2):end));
    peak_right_idx = max(peak_right_idx)+floor(length(vector)/2);
    
    diameter = [];
    if size(vector,1) >1 % have to use if because I don't know the comming vector structure
        left = flipud(vector(1:peak_left_idx));
    else
        left = fliplr(vector(1:peak_left_idx));
    end
    for i = 1:length(left)-2
        if left(i)>(peak_left+baseline_left)/2 && left(i+1)<(peak_left+baseline_left)/2 && left(i+2)<(peak_left+baseline_left)/2
            diameter = [diameter, i];
            break;
        end        
    end
    right = vector(peak_right_idx:end);
    for i = 1:length(right)-2
        if right(i)>(peak_right+baseline_right)/2 && right(i+1)<(peak_right+baseline_right)/2 && right(i+2)<(peak_right+baseline_right)/2
            diameter = [diameter, i];
            break;
        end        
    end
    if length(diameter)>1
        diameter = sum(diameter)+peak_right_idx-peak_left_idx;
    else
        diameter = 0;
        disp('edge too small');
    end
end