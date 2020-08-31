function analysis_roi_oasis(p)
% This function is edited from Andy's same name file.
% The output roivaluest is a struct.
% the last two are not set yet because I didn't test them well. it is
% unconvinent to test code on matlab.


pmt = 2-p.pmt;

%dataDir = correct_folderpath(dataDir);
roiFolder = p.roi.dirname;
mx = load(p.registration_mx_path);
mx = mx.registed_mx;
% if single_trial
%     regp = load(p.registration_parameter_path);
%     mx = dft_clean_edge(mx, {regp.shift + regp.superShife});
% end

if size(mx,3) == 2
    mx = mx(:,:,pmt,:);
end

mx = double(squeeze(mx));

roiMat = FileFind( roiFolder, 'tif', false, @(x)(contains( x, '_' )) );
% use edge as background doesn't work. Need more procise roi setting.
%for i = 1:length(roiMat)
%    if i == 1
%        totalroi = loadTiffStack_slow(roiMat{i,2});
%    else
%        totalroi = totalroi + loadTiffStack_slow(roiMat{i,2});
%    end
%end
%totalroi = uint16((totalroi > 0)*1);
background = loadTiffStack_slow([roiFolder, 'background.tif']);
background = roi_value(mx,background);
roivalues = struct();
for i = 1:length(roiMat)
    roivalues(i).id = roiMat{i,1};
    tmp = strsplit(roivalues(i).id, '_');
    roivalues(i).cellnum = tmp{1};
    roivalues(i).type = tmp{2};
    roivalues(i).map = loadTiffStack_slow(roiMat{i,2});
    %edgemap = roiEdge(roivalues(i).map); %edited
    %edgemap = substract_area(edgemap, totalroi);
    %background = roi_value(mx, edgemap);
    roivalues(i).rawsignal = roi_value(mx,roivalues(i).map);
    fprintf('roi %s done\n',roivalues(i).id);
end

savefolder = [p.dirname,'run', num2str(p.run),'_roicasignal\'];
if ~exist(savefolder, 'dir')
   mkdir(savefolder)
end
save([savefolder, 'result.mat'], 'roivalues', 'background','-v7.3');

end