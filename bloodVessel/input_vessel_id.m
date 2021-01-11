function input_vessel_id(folder)

folder = correct_folderpath(folder);
bvsys = bv_file_system();
resultpath = [folder,bvsys.resultpath];
result = load(resultpath);
result = result.result;
ref = read(Tiff([folder,bvsys.refpath],'r'));

totalpic = length(result.roi);
for j = 1:totalpic
    mask = result.roi{j};
    mask = mask.BW;
    maskmap = addroi(ref, mask);
    subplot(totalpic, 1, j);
    imshow(maskmap);
end

ids = {};
for i = 1:totalpic
    tmp = input(sprintf('please give id for No.%d roi: ', i), 's');
    ids{i} = tmp;
end
for j = 1:totalpic
    result.roi{j}.id = ids{j};
end
save(resultpath, 'result');

end

