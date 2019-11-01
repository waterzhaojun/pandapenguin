function ref_by_seperate_single_file(mx, gap, regPmt)

[r,c,ch,f] = size(mx);
if ch == 1, regPmt = 1; end

pieces = floor(f/gap);
mx2 = mx(:,:,regPmt, 1:pieces*gap);
mx2 = reshape(mx2, [r,c,1,gap,pieces]);
mx2 = mean(mx2, 4);



end