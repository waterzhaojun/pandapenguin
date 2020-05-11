function regMovie = registrate_cross_trials(animal, date, runs, savepath)

upscale = 10;

for i = 1:length(runs)
    p = load_parameters(animal, date, runs(i));
    shiftPara = load(p.registration_parameter_path);
    
    if i == 1
        tmp = shiftPara.super_ref;
        ref = reshape(tmp, [size(tmp),1,1]);
        l1shift = shiftPara.superShife;
    else
        ref(:,:,1,i) = shiftPara.super_ref;
        l1shift = cat(1, l1shift, shiftPara.superShife);
    end
end

% ref = dft_clean_edge(ref, l1shift, upscale); % For some reason, if do
% this step, the decreased size ref can't reg well.
[reged_ref, ref_shift] = dft_piece_registration(ref, upscale);

for i = 1:length(runs)
    p = load_parameters(animal, date, runs(i));
    tmp = load(p.registration_mx_path);
    tmp = tmp.registed_mx;
    tmpshift = repmat(ref_shift(i,:), size(tmp,4),1);
    tmpregedmx = downsample(dft_apply_shift(tmp, tmpshift), p);
    if i == 1
        regMovie = tmpregedmx;
    else
        regMovie = cat(4, regMovie, tmpregedmx);
    end
    fprintf('movie %d done, length %d', i, size(tmpregedmx, 4));
end

regMovie = uint16(regMovie);

mx2tif(regMovie, savepath);

end