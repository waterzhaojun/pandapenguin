function csd_single_trial_analysis(p)

% analysis csd trial
mx = load(p.registration_mx_path);
mx = mx.registed_mx;
csdarray = squeeze(mean(mx(:,:, p.pmt+1,:), [1,2]));
character = csd_character(csdarray);

shiftp = load(p.registration_parameter_path);

mx = dft_clean_edge(mx, shiftp.shift + shiftp.superShife);
mx = mx(:,:,p.pmt+1,character.csd_end_point:end);
mx = uint16(downsample(mx, p));

p.pretreated_mov = [p.basicname, '_postcsdmov.tif'];
p.run = [num2str(p.run), '_postcsd'];
mx2tif(mx, p.pretreated_mov);
analysis_aqua(p);



end