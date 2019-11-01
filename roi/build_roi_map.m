function roimap = build_roi_map(mx, pmt)

if ndims(mx) == 3
    mx= reshape(mx, [size(mx,1), size(mx,2), 1, size(mx,3)]);
end
    
    
[r,c,ch,f] = size(mx);
if ch == 1
    pmt = 1;
end

roimap = zeros(r,c,3);

tmp = squeeze(mean(mx, 4));

roimap(:,:,1) = imnorm(squeeze(mean(mx, 4)));
roimap(:,:,2) = imnorm(squeeze(max(mx, [], 4)));
roimap(:,:,3) = imnorm(squeeze(std(mx, 0, 4)));
roimap = uint16(roimap);


end

function newim = imnorm(im)

tmp = max(im, [], 'all');
newim = im/tmp*65535;

end