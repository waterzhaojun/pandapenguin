function layers = check_scan_layers(info)

if info.volscan == 1
    layers = inf.otparam(3);
else
    layers = 1; % if it is single layer, set z to 1.
end


end