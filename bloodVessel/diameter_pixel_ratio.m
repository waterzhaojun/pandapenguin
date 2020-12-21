function [avg_ratio, x_ratio, y_ratio] = diameter_pixel_ratio(info)

mag = info.config.magnification;
calibration = info.calibration;
x_ratio = calibration(mag).x;
y_ratio = calibration{mag}.y;
avg_ratio = (x_ratio + y_ratio) /2;

end