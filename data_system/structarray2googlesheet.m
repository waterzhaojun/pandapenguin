function structarray2googlesheet(strarray, googlesheetid, gid)
% This function is to save struct array to google sheet.



outputdf_fields = fieldnames(strarray);
mat2sheets(googlesheetid, gid, [1 1], outputdf_fields');

outputdf_data = {};
for i = 1:length(strarray)
    tmp = struct2cell(strarray(i))';
    outputdf_data = [outputdf_data;tmp];
end
mat2sheets(googlesheetid, gid, [2 1], outputdf_data);




end