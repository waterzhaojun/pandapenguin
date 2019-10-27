function csdprocess(parameters)

mov = loadTifStack(parameters.pretreated_mov);
if ndims(mov) > 3 & size(mov, 3)>1
    mov = mov(:,:,parameters.pmt, :);
end
mov = squeeze(mov);
brightness_array = squeeze(mean(mov,[1,2]));





end