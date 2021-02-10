function [diameter, upper_idx, lower_idx] = findEdge(vector, span, method)
    
    % in case the image is dim, we need do smooth first. 
    if nargin < 3, method = 'percentage'; end
    if nargin < 2, span = 11; end

    %vector = medfilt1(vector, span);
    %vector = smooth(vector, span);
    vector = gaussfilt([1:length(vector)], vector, 3);
    
    if strcmp(method, 'kmean')
        % [val ind] = sort(vector,'descend');
        % maxidxes = ind(1:6);
        % grouped_vector = kmeans(vector, 2);
        % vessel_group = round(mean(grouped_vector(maxidxes)));
        % diameter = sum(grouped_vector == vessel_group);
        disp('not a good method');
        
    elseif strcmp(method, 'percentage')
        [peakvalue, peak] = max(vector);
        leftbaseline = min(vector(1:peakidx));
        upper_idx = max(find(vector(1:peakidx)<(peakvalue - leftbaseline) * 0.1));
        rightbaseline = min(vector(peakidx:end));
        lower_idx = min(find(vector(peakidx:end) > (peakvalue - rightbaseline) * 0.1)) + peakidx;
        diameter = lower_idx - upper_idx;
        
    elseif strcmp(method, 'kmean_slope')
        grouped_vector = kmeans(vector, 2);
        sep_value = (mean(vector(grouped_vector == 1)) + mean(vector(grouped_vector == 2)))/2;
        vector_bin = vector>sep_value;
        vector_cross = [];
        % lower_idx = size(vector, 1);
        for i = 1: size(vector, 1)
            vector_cross = [vector_cross, cross_value(vector_bin,i)];
        end
        [~, upper_idx] = max(vector_cross);
        [~, lower_idx] = min(vector_cross);
        diameter = lower_idx - upper_idx;
        
    elseif strcmp(method, 'dark_gap')
        gap_length = 10;
        vector_length = length(vector);
        plot(vector);

        left_vector = vector(1:floor(vector_length/2));
        right_vector = vector(floor(vector_length/2):end);
        left_vector_smooth = smooth(left_vector, gap_length);
        right_vector_smooth = smooth(right_vector, gap_length);
        
        [~, left_low_idx] = min(left_vector_smooth);
        [~, right_low_idx] = min(right_vector_smooth);
        right_low_idx = right_low_idx + floor(vector_length/2)-1;
        
        [~, central_high_idx] = max(smooth(vector(left_low_idx:right_low_idx)));
        central_high_idx = central_high_idx + left_low_idx-1;
        
        %disp(left_low_idx);
        %disp(central_high_idx);
        %disp(right_low_idx);
        
        tmp = vector(left_low_idx:central_high_idx);
        tmp_tilt=[];
        for i = 1:size(tmp,1)
            tmp_tilt = [tmp_tilt, tilt_value(tmp, i)];
        end
        [~, left_idx] = max(tmp_tilt);
        lower_idx = left_idx + left_low_idx;
        %disp(lower_idx);
        
        tmp = vector(central_high_idx:right_low_idx);
        tmp_tilt=[];
        for i = 1:size(tmp,1)
            tmp_tilt = [tmp_tilt, tilt_value(tmp, i)];
        end
        [~, right_idx] = min(tmp_tilt);
        upper_idx = right_idx + central_high_idx;
        diameter = upper_idx - lower_idx;    
        
        %disp(upper_idx);
       % disp(diameter)
        
    end
    
end