function makeRoi_crosstrials_adapter(animal,date,runs)

if true
    disp('Create new ROI map...');
    for i = 1:length(runs)
        disp(i);
        p=load_parameters(animal,date,runs(i));
        regp = load(p.registration_parameter_path);
        refcross = load(p.crosstiral_registration_parameter_path);
        
        tmpedgeshift = regp.shift+regp.superShife;
        tmpedgeshift = tmpedgeshift + repmat(refcross.crosstrial_shift, size(tmpedgeshift,1),1);
        if i ==1
            edgeshift = tmpedgeshift;
        else
            edgeshift = cat(1,edgeshift, tmpedgeshift);
        end
        % Do not use cutted img as ref as the size may be different.
        if ~isfield(refcross,'registed_roimap')
            disp('Does not have registed roimap, start to build new one');
            mx = load(p.registration_mx_path);
            mx = mx.registed_mx; % mx here is just aligned by itself, So need to do a cross align in below code.
            mx = dft_apply_shift(mx,repmat(refcross.crosstrial_shift, size(mx,4),1));
            roimap = build_roi_map(mx,p.pmt);
        else
            disp('Load registed roimap');
            roimap = refcross.registed_roimap;
        end
        
        if i == 1
            crossrefimg =reshape(roimap,[size(roimap),1]);
        else
            crossrefimg = cat(4,crossrefimg,reshape(roimap,[size(roimap),1]));
        end

        roifolder = [p.dirname, 'roi\'];
        if ~exist(roifolder, 'dir')
           mkdir(roifolder);
        end
        
        % refimg need to black the edge before save.
        imwrite(roimap, [roifolder, 'roimap.tif']);
    end
    
    crossroimap_fullsize = uint16(squeeze(max(crossrefimg, [],4)));
    for i = 1:length(runs)
        p=load_parameters(animal,date,runs(i));
        imwrite(crossroimap_fullsize, [p.roi.dirname, 'crossTrialRoiMap.tif']);
        save([p.roi.dirname,'roi_setting.mat'], 'runs','crossroimap_fullsize','edgeshift');
    end
    
    p = load_parameters(animal, date, runs(1));
    choose_roi(crossroimap_fullsize, p.roi.dirname, {edgeshift});
    filelist = dir([p.roi.dirname, '*_*.tif']);
    for i = 2:length(runs)
        tmpp = load_parameters(animal, date, runs(i));
        for j = 1:length(filelist)
            copyfile([filelist(j).folder,'\', filelist(j).name], tmpp.roi.dirname);
        end
    end
end





end