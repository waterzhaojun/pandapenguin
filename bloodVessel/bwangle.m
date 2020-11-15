function [BW, angle, area] = bwangle(pic, varargin)

p = inputParser;
addRequired(p, 'pic');
addParameter(p, 'title', 'Choose a rectangle roi.', @ischar);
parse(p,pic, varargin{:});

roititle = p.Results.title;

imshow(pic);
title(roititle);
[BW, xi, yi] = roipoly(); % xi = col, yi = row
BW = double(BW);
x1 = (xi(1)+xi(2))/2;
y1 = (yi(1)+yi(2))/2;
x2 = (xi(3)+xi(4))/2;
y2 = (yi(3)+yi(4))/2;

xm = x1-x2;
ym = y1-y2;
angle = asin(xm/sqrt(xm^2+ym^2))*180/pi;
disp(['blood vessel angle: ', num2str(angle)]);
area = [min(xi),min(yi), max(xi), max(yi)];
        
end