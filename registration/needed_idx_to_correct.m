function idx = needed_idx_to_correct(ref_idx) 
% need to make a better way to calculate midnum. not just use mean.

diss = ref_idx(2:end) - ref_idx(1:end-1);


standard = max(diss)/5;

%uni = sort(unique(diss));
%midnum = mean(uni);

idx = find(diss > standard);

end