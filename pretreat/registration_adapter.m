function mx = registration_adapter(mx, parameters)


% Which frames should be averaged to form the reference image?
refIm = imread(parameters.refname);
config = parameters.config;
mx = feval(config.fn_registration, mx, refIm, parameters.basicname, config.registratePmt);

end