function [x_ratio, y_ratio] = diameter_pixel_ratio(animal, date, run)

path = sbxPath(animal, date, run, 'sbx'); 
info = sbxInfo(path, true);
mag = info.config.magnification;
calibration = info.calibration;

x_ratio = calibration(mag).x;
y_ratio = calibration(mag).y;

end