function layers = check_scan_layers(info)
% So far I am little confuse about which variable I need to use to check
% level. Until right now I am considering otparam(3) and volscan. length of
% otwave and scanmode are not correct. 
if info.volscan == 1
    layers = info.otparam(3);
elseif info.volscan == 0
    layers = 1; % if it is single layer, set z to 1.
else
    error('Weird I thought volscan should be 0 or 1.');
end


end