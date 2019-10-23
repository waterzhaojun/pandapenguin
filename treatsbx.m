function mx=treatsbx(parameters)

    % step: load config.
    config = parameters.config;
    pname = parameters.basicname;
    disp([parameters.animal, ' -> ',parameters.date, ' -> ', num2str(parameters.run), '  start']);
    
    % step: based on the animal id, date, and run, extract sbx file.
    % The output is a 4 demension matrix by width, height, channel, frame.
    mx = feval(config.fn_extract, parameters);
    disp(size(mx));
    % step: denoise. 
    if config.check_denoise
        mx = feval(config.fn_denoise, mx, parameters);
        pname = [pname, '_denoise'];
        mx2tif(mx, [pname, '.tif'], 0, floor(parameters.scanrate/1), config.denoise_sample_size);
    end
    
    % step: crop.
    mx = feval(config.fn_crop, mx, parameters);
    
    % step: registeration.
    if config.check_registeration
        mx = feval(config.fn_registration, mx, parameters);
        % pname = [pname, '_registeration'];
        % mx2tif(mx, [pname, '.tif'], 0);
    end
    
    % step: downsample.
    mx = feval(config.fn_downsample, mx, parameters);
    
    % final output tif.
    mx2tif(mx, [parameters.basicname, '_pretreated.tif'], 0);
    
    disp([parameters.animal, ' -> ',parameters.date, ' -> ', num2str(parameters.run), '  done']);

end