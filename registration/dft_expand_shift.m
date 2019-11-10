function shift = dft_expand_shift(orishift, idx_list)

% idx_list should start with 0.
if idx_list(1) ~= 0, error('check your idx_list first element, it should be 0'); end

shift = zeros(idx_list(end), size(orishift,2));

for i = 2:length(idx_list)
    sid = idx_list(i-1)+1;
    eid = idx_list(i);
    shift(sid:eid, :) = repmat(orishift(i-1, :), eid-sid+1, 1);
end

end