function makeRoi_adapter(p,create_new_map)

if nargin < 2, create_new_map = false; end
if ~isfield(p,'roi')
    create_new_map = true;
end

if create_new_map
    disp('Create new ROI map...');
    mx = load(p.registration_mx_path);
    mx = mx.registed_mx;
    
    % mx = dft_clean_edge(mx, {regp.shift + regp.superShife});

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

% The shift will be used to cut the edge when roi circled there
regp = load(p.registration_parameter_path);
edgeshift = regp.shift+regp.superShife;

choose_roi(refimg, roifolder,{edgeshift});

end