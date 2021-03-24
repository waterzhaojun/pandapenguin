function change_pdf_2_jpg(folder)
bvfiles = bv_file_system();
path = [correct_folderpath(folder), 'result.mat'];
result = load(path);
result = result.result;
result.response_fig_path = bvfiles.response_fig_path;
save(path, 'result');



end