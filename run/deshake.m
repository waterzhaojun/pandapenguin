function newarray=deshake(array)
% sometime the running wheel counts only because the shaking. This function is to remove the
% shaking. shaking should be continous 1, -1, 1, -1. If abs value above 1,
% it is not a shaking value.


array_nonzero_idx = find(array ~= 0);
array_short = array(array_nonzero_idx);
array_goright = [0,array_short(1:end-1)];
array_goleft = [array_short(2:end),0];
array_combine = (array_short + array_goright) .* (array_short + array_goleft);
array_nonzero_idx = array_nonzero_idx(array_combine > 0);
mask = zeros(1, length(array), 1);
mask(array_nonzero_idx) = 1;
newarray = array .* mask;

end