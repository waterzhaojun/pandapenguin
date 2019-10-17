function ref = ref_from_multiple(animal, date, runs, method, configpath)

gap = 4;

if strcmp(method, 'single')
    for i = 1:length(runs)
        p = load_parameters(animal, date, runs(i), configpath);
        registerPmt = p.config.registerPmt + 1;
        outputpath = [p.refname];
        mx = mxFromSbx(p);
        f = size(mx, 4);
        meanidx = 1:gap:f;
        ref = mean(mx(:,:,registerPmt,meanidx), 4);
        ref = feval(p.config.fn_crop, ref, p);
        ref = uint16(ref);
        imwrite(ref, outputpath, 'tiff');
    end
elseif strcmp(method, 'multiple')
    for i = 1:length(runs)
        p = load_parameters(animal, date, runs(i), configpath);
        registerPmt = p.config.registerPmt + 1;
        outputpath = [p.refname];
        mx = mxFromSbx(p);
        f = size(mx,4);
        meanidx = 1:gap:f;
        if i == 1
            ref = zeros(size(mx,1), size(mx,2), length(runs));
        end
        ref(:,:,i) = mean(mx(:,:,registerPmt,meanidx), 4);
    end
    ref = mean(ref, 3);
    ref = feval(p.config.fn_crop, ref, p);
    ref = uint16(ref);
    for i = 1:length(runs)
        p = load_parameters(animal, date, runs(i), configpath);
        outputpath = [p.refname];
        imwrite(ref, outputpath, 'tiff');
    end
end
       
    




end