function edgemap = edge_idx_to_map(map, edge_idxes, varargin)
parser = inputParser;
addRequired(parser, 'map', @isnumeric);
addRequired(parser, 'edge_idxes', @(x) isnumeric(x) && size(x,1) ==2 );
addParameter(parser, 'border', 3, @(x) isnumeric(x) && isscalar(x) && (x > 0));
addParameter(parser, 'method', 'vertical', @(x) any(validatestring(x,{'vertical', 'horizon', 'square'})));
parse(parser,map, edge_idxes, varargin{:});

method = parser.Results.method;
border = floor(parser.Results.border / 2);

[r,c] = size(map);

edgemap = zeros(r,c);
for i = 1:size(edge_idxes,2)
    edgemap(edge_idxes(1,i),edge_idxes(2,i)) = 1;
end

if any(strcmp(method, {'vertical', 'square'}))
%      for i = 1:size(edge_idxes,2)
%             tmp = zeros(1, size(map,1));
%             tmp(edge_idxes(:,i)) = 1;
%             tmp = tmp + [tmp(2:end),0] + [0, tmp(1:end-1)];
% 
%             edgemap(:, i) = tmp;
%      end
    for i = 1:border
        tmp1 = cat(1,edgemap(1+i:end,:), zeros(i,c));
        tmp2 = cat(1,zeros(i,c), edgemap(1:end-i,:));
        edgemap = edgemap+tmp1+tmp2;
    end
end
if any(strcmp(method, {'square', 'horizon'}))
    for i = 1:border
        tmp1 = cat(2,edgemap(:,1+i:end), zeros(r,i));
        tmp2 = cat(2,zeros(r,i), edgemap(:,1:end-i));
        edgemap = edgemap+tmp1+tmp2;
    end
end

edgemap = uint16((edgemap > 0) * 1);

end