function [distance, angle] = csd_move_distance_with_angle(mx)
% the mx should be the last frame of CSD wave movie, in which the CSD wave
% arraived at the end edge. mx is a 2D matrix.
% the output angle is the radian value (1.57 represent 180 degree).
% distance is the edited distance considered sin(angle).

[r,c] = size(mx);
%fsmooth = smooth2a(mx,10,10);
fkms = reshape(kmeans(reshape(mx,[],1),2),r,c);
cata = round(mean(fkms(:,1)));
fkms = (fkms == cata)*1;
%x = sum(fkms,2);
x = [];
for i = 1:r
    x = [x,turnpoint_1d(fkms(i,:))];
end
y = linspace(1,r,r);
P = robustfit(y,x); % this function ignores the big values.

scatter(x,y,'red');
hold on
plot([100*P(2)+P(1), 400*P(2)+P(1)],[100,400],'blue');
hold off

angle = atan(1/P(2));
distance = c*sin(angle);


end