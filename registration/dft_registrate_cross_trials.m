function ref_clean = dft_registrate_cross_trials(animal, date, runs)
% After cross trial registration, there will be a parameters file saved to
% each trial folder.

upscale = 10;

crosstrials = runs;

for i = 1:length(crosstrials)
    p = load_parameters(animal, date, crosstrials(i));
    shiftPara = load(p.registration_parameter_path);
    
    if i == 1
        tmp = shiftPara.super_ref;
        ref = reshape(tmp, [size(tmp),1,1]);
        l1shift = shiftPara.shift + shiftPara.superShife;
    else
        ref(:,:,1,i) = shiftPara.super_ref;
        l1shift = cat(1, l1shift, shiftPara.shift + shiftPara.superShife);
    end
end

ref_clean = dft_clean_edge(ref, {l1shift}, upscale); 
[~, shift] = dft_piece_registration(ref_clean, upscale);
%regref = dft_apply_shift(ref, shift); % At here I don't consider different trials may have different number of frames, I just mean them equally.

for i = 1:length(crosstrials)
    p = load_parameters(animal, date, crosstrials(i));
    crosstrial_shift = shift(i,:);
    tmp = load(p.registration_mx_path);
    tmp = tmp.registed_mx;
    tmpshift = repmat(crosstrial_shift, size(tmp,4), 1);
    tmp_reged = dft_apply_shift(tmp, tmpshift);
    registed_superref = uint16(squeeze(mean(tmp_reged,4)));
    registed_roimap = build_roi_map(tmp_reged, p.pmt);
    savepath = [p.basicname,'_crosstrial_register_parameters.mat'];
    save(savepath,'crosstrials','crosstrial_shift','registed_superref','registed_roimap','-v7.3'); 
    fprintf('run%s done\n', crosstrials(i));
    
%     
%     tmp = load(p.registration_mx_path);
%     tmp = tmp.registed_mx;
%     tmpshift = repmat(ref_shift(i,:), size(tmp,4),1);
%     tmpregedmx = downsample(dft_apply_shift(tmp, tmpshift), p);
%     if i == 1
%         regMovie = tmpregedmx;
%     else
%         regMovie = cat(4, regMovie, tmpregedmx);
%     end
%     fprintf('movie %d done, length %d', i, size(tmpregedmx, 4));
end

% regMovie = uint16(regMovie);
% 
% mx2tif(regMovie, savepath);

end