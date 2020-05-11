function makeRoi_adapter(p,create_new_map)

try
    create_new_map = ~isfield(p.roi,'mappath')
catch
    create_new_map = 1;
end

if create_new_map
    disp('Create new ROI map...');
    mx = load(p.registration_mx_path);
    mx = mx.registed_mx;
    regp = load(p.registration_parameter_path);

    mx = dft_clean_edge(mx, {regp.shift + regp.superShife});

    refimg = build_roi_map(mx,p.pmt);

    roifolder = [p.dirname, 'roi\'];
    if ~exist(roifolder, 'dir')
       mkdir(roifolder);
    end
    imwrite(refimg, [roifolder, 'roimap.tif']);
else
    disp('Use old ROI map');
    roifolder = p.roi.dirname;
    refimg = imread(p.roi.mappath, 'tif');
end

choose_roi(refimg, roifolder);

end