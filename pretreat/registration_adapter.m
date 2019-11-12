function registed_mx = registration_adapter(mx, parameters)


% Which frames should be averaged to form the reference image?
config = parameters.config;
if ~isfile(parameters.registration_parameter_path)
    build_registration_para(mx, config.piece_size, parameters.registration_parameter_path);
end
regp = load(parameters.registration_parameter_path);
[registed_mx, shift, superShife, registed_ref, super_ref] = feval(config.fn_registration, mx, regp.ref_idx, config.registratePmt);
if any(strcmp({'all', 'mx'}, parameters.config.save_registrated_matrix_and_parameters))
    disp('save the registrated matrix');
    save([parameters.basicname, parameters.config.registrated_matrix_ext, '.mat'], 'registed_mx', '-v7.3');
end
if any(strcmp({'all', 'p'}, parameters.config.save_registrated_matrix_and_parameters))
    disp('save the registrated parameters');
    save([parameters.basicname, parameters.config.registrated_parameters_ext, '.mat'], 'shift', 'superShife', 'registed_ref', 'super_ref', '-append');
end

end