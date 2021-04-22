function res = extractAndyRegData(animal, date, run, varargin)
parser = inputParser;
addRequired(parser, 'animal' );
addRequired(parser, 'date');
addRequired(parser, 'run');
addOptional(parser, 'scanrate', 15.5);
addOptional(parser, 'layer', '1');
addOptional(parser, 'abs', true);
addParameter(parser, 'smooth', true);

parse(parser,animal, date, run, varargin{:});

scanrate = parser.Results.scanrate;
layer = parser.Results.layer;
absdata = parser.Results.abs;
smooth = parser.Results.smooth;

path = sbxDir(animal, date, run);
path = path.runs{1}.andyRegData;

data = load(path);
data = data.tforms_all;

res = struct();
res(1).scanrate = scanrate;
res(1).layer = layer;
res(1).trans_x = [];
res(1).trans_y = [];
res(1).trans = [];
res(1).scale_x = [];
res(1).scale_y = [];
res(1).scale = [];
res(1).shear_x = [];
res(1).shear_y = [];
res(1).shear = [];
for f = 1:length(data) % 1:Nplane
    res(1).trans_x = [res(1).trans_x, data{f}.T(3,1)];
    res(1).trans_y = [res(1).trans_y, data{f}.T(3,2)];
    res(1).trans = [res(1).trans, sqrt(data{f}.T(3,1)^2 + data{f}.T(3,2)^2)]; 
    
    res(1).scale_x = [res(1).scale_x, data{f}.T(1,1)];
    res(1).scale_y = [res(1).scale_y, data{f}.T(2,2)];
    res(1).scale = [res(1).scale, sqrt(data{f}.T(1,1)^2 + data{f}.T(2,2)^2)];
    
    res(1).shear_x = [res(1).shear_x, data{f}.T(1,2)];
    res(1).shear_y = [res(1).shear_y, data{f}.T(2,1)];
    res(1).shear = [res(1).shear, sqrt(data{f}.T(1,2)^2 + data{f}.T(2,1)^2)];
end

if absdata
    res(1).trans_x = abs(res(1).trans_x);
    res(1).trans_y = abs(res(1).trans_y);
    res(1).scale_x = abs(res(1).scale_x);
    res(1).scale_y = abs(res(1).scale_y);
    res(1).shear_x = abs(res(1).shear_x);
    res(1).shear_y = abs(res(1).shear_y);
end

if smooth
    res(1).trans_x = gaussfilt(1:length(res(1).trans_x), res(1).trans_x, 3);
    res(1).trans_y = gaussfilt(1:length(res(1).trans_y), res(1).trans_y, 3);
    res(1).scale_x = gaussfilt(1:length(res(1).scale_x), res(1).scale_x, 3);
    res(1).scale_y = gaussfilt(1:length(res(1).scale_y), res(1).scale_y, 3);
    res(1).shear_x = gaussfilt(1:length(res(1).shear_x), res(1).shear_x, 3);
    res(1).shear_y = gaussfilt(1:length(res(1).shear_y), res(1).shear_y, 3);
end
    

end