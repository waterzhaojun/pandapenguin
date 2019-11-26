function build_csd_registration_para(parameters)

mx = mxFromSbx(parameters);
mx = trimMatrix(mx, parameters);
csdarray = squeeze(mean(mx, [1,2]));
csdcharacter = csd_character(csdarray);

f = size(mx,4);

piece_size = parameters.config.piece_size;
max_piece_size = 1.5 * piece_size;

csd_piece_num = floor((csdcharacter.csd_end_point +60*15 - csdcharacter.csd_start_point)/(15*2));

ref_idx = floor([0, linspace(csdcharacter.csd_start_point, csdcharacter.csd_end_point+60*15, csd_piece_num)]);

endidx = ref_idx(end);
while endidx + max_piece_size < f
    ref_idx = [ref_idx, endidx + piece_size];
    endidx = endidx + piece_size;
end
if ref_idx(end) ~= f
    ref_idx = [ref_idx, f];
end

save(parameters.registration_parameter_path, 'ref_idx');




end