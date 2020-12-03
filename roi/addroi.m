function refmap = addroi(ref, newroi, text, varargin)
p = inputParser;
addRequired(p, 'ref');
addRequired(p, 'newroi');
addOptional(p, 'text', '');
addParameter(p, 'alpha', 0.4, @(x) isnumeric(x) && (x >= 0) && (x <= 1));
addParameter(p, 'color', 'b', @(x) any(validatestring(x,{'r', 'g', 'b'})));
parse(p,ref, newroi, text, varargin{:});

alpha = p.Results.alpha;
switch p.Results.color
    case 'r'
        ch = 1;
    case 'g'
        ch = 2;
    case 'b'
        ch = 3;
end

if ndims(ref) == 2
    refmap = double(repmat(ref,[1 1 3]));
elseif ndims(ref) == 3
    refmap = double(ref);
else
    error('ref should be a 2D pic or 3D color pic');
end

newroimx = repmat(1 - double(newroi)*alpha, [1,1,3]);
newroimx(:,:,ch) = ones(size(newroi));
refmap = refmap .* newroimx;

% add label function. Not install yet.
% if ~strcmp(num2str(text), '')
%     insertText(refmap, bwcenter(newroi), num2str(text));
% end

refmap = uint16(refmap);

end