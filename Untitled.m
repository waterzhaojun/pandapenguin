aaa = {'DL159', '190612', 8; 'DL170', '190613', 6; 'DL171', '190614', 8;'DL172','190617',9;'DL173','190620',6;'DL174','190622',4;'RAS001','190913',3;'RAS002','190916',3;'RAS003','190917',3;'RAS004','190920',3}

[r,c] = size(aaa);
for i =1:r
    csd_cperiod_bigmovie(aaa{i,1}, aaa{i,2}, aaa{i,3});
    disp(i);
%     p = load_parameters(aaa{i,1}, aaa{i,2}, aaa{i,3});
%     mx = mxFromSbx(p);
%     mx = denoise(mx, p);
%     mx = trimMatrix(mx, p);
%     mx = apply_shift(mx, p);
%     csd_movie_path = [p.dirname, 'run', num2str(p.run), '_CSD\'];
%     mx2tif(mx, [csdfolder, '
end
    

root = 'C:\2pdata\DL159\190612_DL159\190612_DL159_run8\test_test_run0\';

p = struct();
p.pretreated_mov = [root, 'DL159_190612_007_csd_C_mov_1hz.tif'];
p.config.related_setting_file.aqua_parameter_file = [root, 'aqua_csd_parameters.yml'];

p.run = '0'

analysis_aqua(p);



mx = loadTiffStack_slow('C:\2pdata\DL159\190612_DL159\190612_DL159_run8\csd_raw_smoothed_cropped.tif');



mx2tif(uint16(mx), 'C:\2pdata\DL159\190612_DL159\190612_DL159_run8\test_test_run0\DL159_190612_007_csd_C_mov_big_1hz.tif', 0, 15);