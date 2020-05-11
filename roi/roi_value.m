function value = roi_value(mx, roimap)
    % The mx here suppose is a 3D matrix
    pix = sum(roimap,'all');
    roimap = repmat(roimap,[1,1,size(mx,3)]);
    value = roimap.*mx;
    value = squeeze(sum(value,[1,2]))/pix;
end