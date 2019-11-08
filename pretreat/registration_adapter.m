function mx = registration_adapter(mx, parameters)


% Which frames should be averaged to form the reference image?
refIm = imread(parameters.refname);
config = parameters.config;
if ~isfile(config.registrateParaPath)
    build_registration_para(mx, config.piece_size, config.registrateParaPath);
end
load(config.registrateParaPath);
mx = feval(config.fn_registration, mx, keyIdxArray, parameters.basicname, config.registratePmt);


end