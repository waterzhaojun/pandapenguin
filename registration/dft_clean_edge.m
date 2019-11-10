function cleanmx = dft_clean_edge(mx, shift, upscale)

% This function is to clean the registrated mx's edge. duration
% registration each frame move differently, so the edge are different.
% Based on the shift, we crop the edge to remove the noisy edge. the input
% mx should be registrated but not cleaned the edge. shift is the variable
% that return from registration, which has f x 5 size.

% The mx could be multiple channels as all channels are registrated based
% on one channel, so one channels shift can be used for all channels
% cropping.

[r,c,ch,f] = size(mx);
r_start = abs(min(shift(:,2))*upscale);
r_end = max(shift(:,2))*upscale;
c_start = abs(min(shift(:,1))*upscale);
c_end = max(shift(:,1))*upscale;
cleanmx = mx( r_start : end-r_end, c_start:end-c_end, :, :);

end