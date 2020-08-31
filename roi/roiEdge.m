function edgemap = roiEdge(roimap)

roimap = imfill(roimap,'holes');
an = cat(1, roimap(2:end, :), zeros(1, size(roimap,2)));
as = cat(1, zeros(1, size(roimap,2)), roimap(1:end-1, :));
ae = cat(2, zeros(size(roimap,1),1), roimap(:, 1:end-1));
aw = cat(2, roimap(:, 2:end), zeros(size(roimap,1),1));

edgemap = roimap+an+as+ae+aw;
edgemap = (edgemap >0)*1-roimap;

edgemap = uint16(edgemap);

end