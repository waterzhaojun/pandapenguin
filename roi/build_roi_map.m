function roimap = build_roi_map(mx, pmt)

if nargin < 2
    pmt = 0;
end

if ndims(mx) == 3
    mx= reshape(mx, [size(mx,1), size(mx,2), 1, size(mx,3)]);
end
    
[r,c,ch,f] = size(mx);
if ch == 1
    pmt = 0;
end

mx = mx(:,:,pmt+1,:);

roimap = zeros(r,c,3);

% tmp = squeeze(mean(mx, 4));

roimap(:,:,1) = imadjust(uint16(squeeze(mean(mx, 4)))); %imnorm
roimap(:,:,2) = imadjust(uint16(squeeze(max(mx, [], 4))));
roimap(:,:,3) = imadjust(uint16(squeeze(std(double(mx), 0, 4))));
roimap = uint16(roimap);


end
