function regmx = apply_shift(mx, p, fn)
% this function is different to rgistration/dft_apply_shift.m. That
% function is to apply shift values to mx. But this function is to directly apply this trial's several different
% level's shift value to the mx and also clean the edge at the end. It is like a high level api to apply shift to mx. 

% This function is not in first time pretreat.

if nargin < 3, fn = 'dft'; end
reg_para = load(p.registration_parameter_path);
if strcmp(fn, 'dft')
    regmx = dft_apply_shift(mx, reg_para.shift);
    regmx = dft_apply_shift(regmx, reg_para.superShife);
end

regmx = dft_clean_edge(regmx, {reg_para.shift + reg_para.superShife});

regmx = uint16(regmx);


end