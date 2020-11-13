function [diameter_value, mov, centroid] = vertical_diameter_measure(mx, varargin)

parser = inputParser;
addRequired(parser, 'pic', @isnumeric);
addParameter(parser, 'gaussianFilterSize', 4, @isnumeric);
addParameter(parser, 'areaopenSize', 8, @isnumeric);
addParameter(parser, 'ch', 1, @(x) isnumeric(x) && (x>0) && (x<3));
parse(parser,mx, varargin{:});

ch = parser.Results.ch;
gaussianFilterSize = parser.Results.gaussianFilterSize;
areaopenSize = parser.Results.areaopenSize;
f = size(mx,4);
diameter_value = zeros(1,f);
mov = zeros(size(mx,1),size(mx,2),3,f);
%mov(:,:,1,:) = mx;
for i=1:f
    x = imadjust(uint16(imgaussfilt(mx(:,:,ch,i),gaussianFilterSize)));
    b = imbinarize(x);
    b = bwareaopen(b,areaopenSize);
    [border,area] = bwboundaries(b,'noholes');
    stats = regionprops(area,'Area','Centroid');
    if length(stats) > 1
        T = struct2table(stats); % convert the struct array to a table
        T = sortrows(T, 'Area', 'descend'); % sort the table by 'DOB'
        stats = table2struct(T);
        stats = stats(1);
    end
    
    diameter_value(i) = sqrt(stats.Area / pi);
    centroid = stats.Centroid;
    mov(:,:,1,i) = x;
    mov(:,:,3,i) = imadjust(edge_idx_to_map(area,border{1,1}', 'method', 'square'));
end
mov = reshape(mov, size(mov,1), size(mov,2), []);
mov = uint16(mov);

end