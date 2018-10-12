function diameter = findEdge_nonlabel(vector, span)
    
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
    
    diameter = max(0, peak_right_idx - peak_left_idx);
    
end