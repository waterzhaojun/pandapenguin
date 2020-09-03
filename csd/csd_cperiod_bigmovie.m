function csd_cperiod_bigmovie(animal, date, run, pmt)

% This function is to produce CSD wave period movie. It need pre-analyzed
% csd characters. 

if nargin < 4, pmt =0; end

p = load_parameters(animal, date, run, pmt);
mx = mxFromSbx(p);
mx = denoise(mx, p);
mx = trimMatrix(mx, p);
mx = apply_shift(mx, p);
[p0,p1] = fileparts(p.basicname);
result_path = [p.dirname, 'run', num2str(p.run), '_CSD\result.mat'];
csd_movie_path = [p.dirname, 'run', num2str(p.run), '_CSD\', p1, '_csd_C_mov_fullsize.tif'];

result = load(result_path);

mx = mx(:,:,:,result.csd_start_point:result.csd_end_point);
mx2tif(mx, csd_movie_path, 0, 15);

end