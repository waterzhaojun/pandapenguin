function wheel_run_data(path, bint, absolute)

if nargin<3, absolute = true; end
if bint <2, bint = 1; end

run = load(path);
run = run.quad_data;

run_ref = cat(2, 0, run(1:length(run)-1));

run_final = run-run_ref;

if absolute
    run_final = abs(run_final);
end

res = bint_1d(run_final, bint, 'sum');

% res = reshape(res, [], 1);

% output the data to local folder
[foldername,filename, extname] = fileparts(path);
output_filename = strcat(foldername, '\wheelrun.csv');
csvwrite(output_filename,res);