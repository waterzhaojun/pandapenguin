function mx2tif_v2(mx, path, varargin)
% This function is to build a tif from a given matrix. The matrix is
% suppose to be 4D or 2D. If given a 3D matrix, it will transfer it to 4D and
% set 3rd dimension to 1. IF it is a 2D, the output is a tif pic.
% If 3rd dimension is 1, you can set 'color' to 'r' or 'g' or 'b'. This
% won't work if 3rd dimension is bigger than 1. 
% 3rd = 1 is a gray mov. 
% 3rd = 2 is a color tif. You can set color to an array like ['g','r'] to
% define the color. The default is 'r','g'.
% 3rd = 3 is a color mov. Like 3rd = 2, you can set the color by array. The
% default is ['r','g','b'].
% The 4rd dimension is frames for time course.
% This function will always output uint16 tif. If you want different type,
% set 'filetype' to 'uint8' or 'double'.

parser = inputParser;
addRequired(parser, 'mx');
addRequired(parser, 'path', @ischar);
addOptional(parser, 'color', ['r','g','b']); %, @(x) any(validatestring(x,{'r','g','b'})));
addOptional(parser, 'filetype', 'uint16', @(x) any(validatestring(x, {'uint16','uint8', 'double'})));
parse(parser,mx, path, varargin{:});

color = parser.Results.color;
filetype = parser.Results.filetype;

if ndims(mx) == 2, mx = reshape(mx, size(mx,1),size(mx,2),1); end
if ndims(mx) == 3, mx = reshape(mx, size(mx,1),size(mx,2),1,size(mx,4)); end
[r,c,ch,f] = size(mx);
    
% pretreat the mx based on the color
missc = [];
allc = ['r','g','b'];
colorlist = [];
for i = 1:length(color)
    if any(allc == color(i))
        colorlist = [colorlist, find(allc == color(i))];
    end
end

mx = feval(filetype, mx);

if exist(path, 'file') == 2, delete(path); end

% produce the tiff
for i = 1:f
    if ch == 1
        imwrite(squeeze(mx(:,:,:,i)), path, 'WriteMode', 'append');
    else
        tmp = zeros(r,c,3);
        for j = 1:ch
            tmp(:,:,colorlist(j)) = uint8(mx(:,:,j,i));
        end
        imwrite(squeeze(mx(:,:,:,i)), path, 'WriteMode', 'append');
    end
    % the follow part may rewrite to a shorter version.
    loopNotice(i,f);
end