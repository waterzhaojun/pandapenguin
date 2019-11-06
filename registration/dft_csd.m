function dft_csd(mx, ref, shift_file_name, refPmt)

csdarray = squeeze(mean(mx, [1,2]));
csdcharacter = csd_character(csdarray);

reg_points = [1, csdcharacter.csd_start_point, csdcharacter.csd_end_point, size(mx, 4)];

ref = zeros(size(mx, 1), size(mx, 2), 1, length(reg_points)-1);
reg = zeros(size(mx));
for i = 1:size(ref, 4)
    ref(:,:,1,i) = mean(mx(:,:,1,reg_points(i):reg_points(i+1)), 4);
    reg(:,:, = dft_190928(mx(:,:,1,reg_points(i):reg_points(i+1)), uint16(ref(:,:,1,i)), '', 1);
end

% this function didnot finish yet


end