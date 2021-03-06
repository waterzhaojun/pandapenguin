function res = bv_file_system()
res = struct();
res.movpath = 'mov.tif';
res.refpath = 'ref.tif';
res.ref_with_mask_path = 'ref_with_mask.tif';
res.resultpath = 'result.mat';
res.response_fig_path = 'response.jpg';
res.bv_running_correlation_pdf = 'bv_running_correlation.pdf';
res.folderpath = 'bv';
res.bv_running_correlation_folderpath = 'bv_running_correlation';
res.bv_running_correlation_resultpath = [res.bv_running_correlation_folderpath, '\result.mat'];
res.bv_running_correlation_individualfigpath = [res.bv_running_correlation_folderpath, '\ROI_BOUT.svg'];

res.roi = {};


end