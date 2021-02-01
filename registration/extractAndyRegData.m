function res = extractAndyRegData(path)

data = load(path);
data = data.tforms_all;

res = struct();
res(1).trans_x = [];
res(1).trans_y = [];
res(1).scale_x = [];
res(1).scale_y = [];
res(1).shear_x = [];
res(1).shear_y = [];
for f = 1:length(data) % 1:Nplane
    res(1).trans_x = [res(1).trans_x, data{f}.T(3,1)];
    res(1).trans_y = [res(1).trans_y; data{f}.T(3,2)];
    res(1).scale_x = [res(1).scale_x, data{f}.T(1,1)];
    res(1).scale_y = [res(1).scale_y, data{f}.T(2,2)];
    res(1).shear_x = [res(1).shear_x, data{f}.T(1,2)];
    res(1).shear_y = [res(1).shear_y, data{f}.T(2,1)];
end


end