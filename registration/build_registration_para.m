function build_registration_para(mx, piece_size, savepath)

f = size(mx, 4);

max_piece_size = 1.5 * piece_size;

% define piece idx
ref_idx = [0];
endidx = 0;
while endidx + max_piece_size < f
    ref_idx = [ref_idx, endidx + piece_size];
    endidx = endidx + piece_size;
end
if ref_idx(end) ~= f
    ref_idx = [ref_idx, f];
end

save(savepath, 'ref_idx');
% not done yet, have to identify the last piece can't less than xxxx.
end