function analysis_aqua_adapter(path, parameter_filepath)
% for temporally use only

p = struct();
p.pretreated_mov = path;
p.config.related_setting_file.aqua_parameter_file = parameter_filepath;

% run name part is very tricky. It make it vary case by case.
[p0,f0,f1] = fileparts(path);
[tmp0, tmp1, tmp] = fileparts(p0);
tmp = strsplit(tmp1, '_');
tmp = strsplit(tmp{1}, 'run');
tmp = tmp{2};
p.run = [tmp,'_csdC'];

analysis_aqua(p);


end