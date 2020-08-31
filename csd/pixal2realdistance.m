function speed = pixal2realdistance(distance,angle,p)
% This function is to help calculate csd speed. If you set well, it can
% also help you calculate other speed. 
% angle is the angle between csd wave frontline and bottom edge.
% distance is the pixal csd moved vertical to the frontline.

info = load([p.basicname, '.mat']);
mag = info.info.config.magnification;
xrate = info.info.calibration(mag).x;
yrate = info.info.calibration(mag).y;

speed = distance * sqrt(power(cos(angle)*yrate,2) + power(sin(angle)*xrate,2));

end