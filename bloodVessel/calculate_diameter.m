function [diameter_value, response_fig, response_mov, edge_idx_of_line] = calculate_diameter(mx, BW, angle, varargin)

parser = inputParser;
addRequired(parser, 'mx', @isnumeric);
addRequired(parser, 'BW', @isnumeric);
addRequired(parser, 'angle', @isnumeric);
parse(parser,mx, BW, angle, varargin{:});

BW_rotated = imrotate(BW, angle);
[r,c] = find(BW_rotated == 1);
upper = min(r);
lower = max(r);
left = min(c);
right = max(c);
BW_rotated_crop = BW_rotated(upper:lower,left:right);
weight_line = sum(BW_rotated_crop, 1);

raw_res_fig = zeros(size(BW_rotated_crop,2), size(mx,4));
response_mov = zeros([size(BW_rotated_crop), 1,size(mx,4)]);

for i=1:size(mx,4)

    tmp = imrotate(squeeze(mx(:, :, :, i)), angle);
    tmp = double(tmp(upper:lower,left:right)) .* BW_rotated_crop;
    response_mov(:,:,1,i) = imadjust(uint16(tmp));
    raw_res_fig(:,i) = sum(tmp, 1)./weight_line;

    loopNotice(i,size(mx,4));

end

diameter_value = zeros([1, size(raw_res_fig,2)]);
edge_idx_of_line = zeros([2, size(raw_res_fig,2)]);
for i=1:size(raw_res_fig,2)
    [diameter_value(1, i), edge_idx_of_line(1, i), edge_idx_of_line(2, i)] = findEdge(raw_res_fig(:,i));
end

edge_map = edge_idx_to_map(raw_res_fig, edge_idx_of_line);
response_fig = zeros([size(raw_res_fig),3]);
response_fig(:,:,1) = imadjust(uint16(raw_res_fig));
response_fig(:,:,3) = imadjust(uint16(edge_map));


end