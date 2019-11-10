function build_csd_registration_para(parameters)

mx = mxFromSbx(parameters);
mx = trimMatrix(mx, parameters);
csdarray = squeeze(mean(mx, [1,2]));
csdcharacter = csd_character(csdarray);

f = size(mx,4);

piece_size = parameters.config.piece_size
max_piece_size = 1.5 * piece_size;

ref_idx = [0, csdcharacter.csd_start_point, csdcharacter.csd_end_point];
endidx = csdcharacter.csd_end_point;
while endidx + max_piece_size < f
    ref_idx = [ref_idx, endidx + piece_size];
    endidx = endidx + piece_size;
end
if ref_idx(end) ~= f
    ref_idx = [ref_idx, f];
end

save(parameters.registration_parameter_path, 'ref_idx');



end