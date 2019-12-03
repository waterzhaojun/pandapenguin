function makeRoi_adapter(p)

mx = load(p.registration_mx_path);
mx = mx.registed_mx;
regp = load(p.registration_parameter_path);

mx = dft_clean_edge(mx, regp.shift + regp.superShife);

refimg = imadjust(uint16(squeeze(mean(mx, 4))));

roifolder = [p.dirname, 'roi\'];

choose_roi(refimg, roifolder);

end