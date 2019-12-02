function newmx = remove_blank_frame(mx)

[r,c,ch,f] = size(mx);
if ch > 1
    error('This only support 1 channel mx');
end
s = squeeze(sum(mx, [1,2]));

fs = find(s == 0);

mx(:,:,:,fs) = [];

newmx = mx;

end