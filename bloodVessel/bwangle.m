function [BW, angle, area] = bwangle(pic)

[BW, xi, yi] = roipoly(pic); % xi = col, yi = row
BW = double(BW);
x1 = (xi(1)+xi(2))/2;
y1 = (yi(1)+yi(2))/2;
x2 = (xi(3)+xi(4))/2;
y2 = (yi(3)+yi(4))/2;

xm = x1-x2;
ym = y1-y2;
angle = asin(xm/sqrt(xm^2+ym^2))*180/pi;
disp(['blood vessel angle: ', num2str(angle)]);
disp(xi)
disp(yi)
area = [min(xi),min(yi), max(xi), max(yi)];
        
end