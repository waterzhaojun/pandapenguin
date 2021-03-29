function [maxangle, snr, var_list, radon_map] = radon_transformation(m, varargin)
% This algorithm is to use radon transform to calculate the angle that best
% transform the image to let it have maxium variance.
% The output's first dimension is each pixel's value sum at specific angle. 
% The second dimension is specific angle.
% If the maxangle is negative number, means the image rotate clockwise. 
parser = inputParser;
addRequired(parser, 'm'); % m is a 2D array
addOptional(parser, 'angle_range', [-90:90]); % The image rotate around the center.
parse(parser,m, varargin{:});

angle_range = parser.Results.angle_range;

mone = ones(size(m));
radon_map = radon(m, angle_range);
% Instead of use radon transform's sum value, I need to use average value
% of each beam.
radon_mone = radon(mone, angle_range);
radon_mone = ceil(radon_mone);
radon_mone(find(radon_mone == 0)) = 1;

radon_map = radon_map ./ radon_mone;

% Start to calculate
[r,c] = size(radon_map);
var_list = [];
for i = 1:c
    posindex = radon_map(:,i) ~= 0;
    tmp = var(radon_map(posindex, i));
    var_list = [var_list, tmp];
end


[maxvar,maxidx] = max(var_list);
maxangle = angle_range(maxidx);

snr = maxvar / mean(var_list);

end
