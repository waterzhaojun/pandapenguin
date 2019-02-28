function [diameter, upper_idx, lower_idx] = findEdge(vector, span, method)
    
    % in case the image is dim, we need do smooth first. 
    if nargin < 3, method = 'kmean_slope'; end
    if nargin < 2, span = 11; end

    vector = medfilt1(vector, span);
    %vector = smooth(vector, span);
    
    if strcmp(method, 'kmean')
        % [val ind] = sort(vector,'descend');
        % maxidxes = ind(1:6);
        % grouped_vector = kmeans(vector, 2);
        % vessel_group = round(mean(grouped_vector(maxidxes)));
        % diameter = sum(grouped_vector == vessel_group);
        disp('not a good method');
        
    elseif strcmp(method, 'kmean_slope')
        grouped_vector = kmeans(vector, 2);
        sep_value = (mean(vector(grouped_vector == 1)) + mean(vector(grouped_vector == 2)))/2;
        vector_bin = vector>sep_value;
        vector_cross = [];
        % lower_idx = size(vector, 1);
        for i = 1: size(vector, 1);
            vector_cross = [vector_cross, cross_value(vector_bin,i)];
        end
        [~, upper_idx] = max(vector_cross);
        [~, lower_idx] = min(vector_cross);
        diameter = lower_idx - upper_idx;
        
    end
    
end