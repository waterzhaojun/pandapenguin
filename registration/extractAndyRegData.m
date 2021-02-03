function res = extractAndyRegData(animal, date, run, varargin)
parser = inputParser;
addRequired(parser, 'animal' );
addRequired(parser, 'date');
addRequired(parser, 'run');
addOptional(parser, 'scanrate', 15.5);
addOptional(parser, 'layer', '1');
addOptional(parser, 'abs', true);
parse(parser,animal, date, run, varargin{:});

scanrate = parser.Results.scanrate;
layer = parser.Results.layer;

path = sbxDir(animal, date, run);
path = path.runs{1}.andyRegData;

data = load(path);
data = data.tforms_all;

res = struct();
res(1).scanrate = scanrate;
res(1).layer = layer;
res(1).trans_x = [];
res(1).trans_y = [];
res(1).scale_x = [];
res(1).scale_y = [];
res(1).shear_x = [];
res(1).shear_y = [];
for f = 1:length(data) % 1:Nplane
    res(1).trans_x = [res(1).trans_x, data{f}.T(3,1)];
    res(1).trans_y = [res(1).trans_y, data{f}.T(3,2)];
    res(1).scale_x = [res(1).scale_x, data{f}.T(1,1)];
    res(1).scale_y = [res(1).scale_y, data{f}.T(2,2)];
    res(1).shear_x = [res(1).shear_x, data{f}.T(1,2)];
    res(1).shear_y = [res(1).shear_y, data{f}.T(2,1)];
end

if parser.Results.abs
    res(1).trans_x = abs(res(1).trans_x);
    res(1).trans_y = abs(res(1).trans_y);
    res(1).scale_x = abs(res(1).scale_x);
    res(1).scale_y = abs(res(1).scale_y);
    res(1).shear_x = abs(res(1).shear_x);
    res(1).shear_y = abs(res(1).shear_y);
end

end