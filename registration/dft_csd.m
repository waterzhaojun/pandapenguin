function regMovie = dft_csd(mx,shift_file_name, refPmt)

csdarray = squeeze(mean(mx, [1,2]));
csdcharacter = csd_character(csdarray);

reg_points = [1, csdcharacter.csd_start_point, csdcharacter.csd_end_point, size(mx, 4)];

ref = zeros(size(mx, 1), size(mx, 2), 1, length(reg_points)-1);
regMovie = zeros(size(mx));
xyshift = zeros(length(reg_points)-1, 4);
for i = 1:size(ref, 4)
    [regMovie(:,:,:,reg_points(i):reg_points(i+1)), ref(:,:,1,i), xyshift(i,:)] = dft_191105(mx(:,:,:,reg_points(i):reg_points(i+1)), '', '', refPmt);
end

% this function didnot finish yet


end