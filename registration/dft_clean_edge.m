function cleanmx = dft_clean_edge(mx, shift, upscale)

% This function is to clean the registrated mx's edge. duration
% registration each frame move differently, so the edge are different.
% Based on the shift, we crop the edge to remove the noisy edge. the input
% mx should be registrated but not cleaned the edge. shift is the variable
% that return from registration, which has f x 5 size.

% The mx could be multiple channels as all channels are registrated based
% on one channel, so one channels shift can be used for all channels
% cropping.

% mx and shift do not need to have the same length.

[r,c,ch,f] = size(mx);
r_start = 1 + ceil(max(shift(:,2) .* (shift(:,2)>0)));
r_end = r - ceil(abs(min(shift(:,2) .* (shift(:,2)<0))));
c_start = 1 + ceil(max(shift(:,1) .* (shift(:,1)>0)));
c_end = c - ceil(abs(min(shift(:,1) .* (shift(:,1)<0))));
disp(['keep r from ', num2str(r_start), ' to ', num2str(r_end)]);
disp(['keep c from ', num2str(c_start), ' to ', num2str(c_end)]);
cleanmx = mx( r_start : r_end, c_start : c_end, :, :);

end