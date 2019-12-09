function mx=treatsbx(p)

    % step: load config.
    config = p.config;
    pname = p.basicname;
    disp([p.animal, ' -> ',p.date, ' -> ', num2str(p.run), '  start']);
    
    % step: based on the animal id, date, and run, extract sbx file.
    % The output is a 4 demension matrix by width, height, channel, frame.
    mx = mxFromSbx(p); %feval(config.fn_extract, parameters);
    disp(size(mx));
    
    % step: denoise. 
    if config.check_denoise
        mx = feval(config.fn_denoise, mx, p);
        pname = [pname, '_denoise'];
        if config.output_denoised_sample
            mx2tif(mx, [pname, '.tif'], config.output_sample_channel, floor(p.scanrate/1), config.denoise_sample_size);
        end
    end
    
    % step: crop.
    mx = feval(config.fn_crop, mx, p);
    
    % step: registeration.
    if config.check_registration
        mx = registration_adapter(mx, p);
    end
    
    % step: downsample.
    mx = feval(config.fn_downsample, mx, p);
    
    % final output tif.
    mx2tif(mx, [p.basicname, '_pretreated.tif'], 0);
    
    disp([p.animal, ' -> ',p.date, ' -> ', num2str(p.run), '  done']);

end