function mx = registration_adapter(mx, parameters)


% Which frames should be averaged to form the reference image?
refIm = imread(parameters.refname);
config = parameters.config;
if ~isfile(parameters.registration_parameter_path)
    build_registration_para(mx, config.piece_size, parameters.registration_parameter_path);
end
regp = load(parameters.registration_parameter_path);
mx = feval(config.fn_registration, mx, regp.ref_idx, parameters.refname, parameters.registration_parameter_path, config.registratePmt);


end