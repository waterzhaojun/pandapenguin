function [diameter_value, response_fig, mov, centroid] = vertical_diameter_measure(mx, BW, varargin)

parser = inputParser;
addRequired(parser, 'rawmx', @(x) isnumeric(x) && (size(x,3) == 1));
addRequired(parser, 'BW', @isnumeric);
addParameter(parser, 'gaussianFilterSize', 4, @isnumeric);
addParameter(parser, 'areaopenSize', 8, @isnumeric);
addParameter(parser, 'ch', 1, @(x) isnumeric(x) && (x>0) && (x<3));
parse(parser,mx, BW, varargin{:});

ch = parser.Results.ch;
gaussianFilterSize = parser.Results.gaussianFilterSize;
areaopenSize = parser.Results.areaopenSize;

[rr,cc] = find(BW);
mxcrop = mx(min(rr):max(rr),min(cc):max(cc),:,:);
f = size(mxcrop,4);
diameter_value = zeros(1,f);
response_fig = zeros(size(mxcrop,1), f,3);
mov = zeros(size(mxcrop,1),size(mxcrop,2),3,f);
centroid = zeros(2,f);

for i=1:f
    x = imadjust(uint16(imgaussfilt(mxcrop(:,:,ch,i),gaussianFilterSize)));
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
    
    diameter_value(i) = 2 * sqrt(stats.Area / pi);
    centroid(:,i) = stats.Centroid;
    
    mov(:,:,:,i) = repmat(x,[1,1,3]);
    mov(:,:,3,i) = mov(:,:,3,i) + double(imadjust(edge_idx_to_map(area,border{1,1}', 'method', 'square')));
    
    response_fig(:,i,:) = mov(:,floor(centroid(2,i)),:,i);
end

response_fig = uint16(response_fig);
mov = uint16(mov);

mov = reshape(mov, size(mov,1), size(mov,2), []);


end