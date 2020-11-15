function newBW = vertical_mask(BW)

% This function is to convert the normal roi to a formated rectangle roi
% for vertical vessel.

[r,c] = find(BW);
rmin = min(r);
rmax = max(r);
cmin = min(c);
cmax = max(c);

newBW = zeros(size(BW));
newBW(rmin:rmax, cmin:cmax) = 1;

end