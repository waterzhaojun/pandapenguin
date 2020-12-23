function [animal, date, run] = pathTranslate(path)
% This function is to convert a path to animal, date, run.

root = correct_folderpath(sbxScanbase());
path = path(length(root)+1:end);
tmp = strsplit(path, '\');
animal = tmp{1};
date = strsplit(tmp{2}, '_');
date = date{1};
run = strsplit(tmp{3}, 'run');
run = str2num(run{2});




end
