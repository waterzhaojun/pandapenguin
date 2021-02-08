function scanrate = check_scan_rate(inf)
% So far I am little confuse about which variable I need to use to check
% level. Until right now I am considering otparam(3) and volscan. length of
% otwave and scanmode are not correct. 
if inf.scanmode == 1
    scanrate = 15.5;
elseif inf.scanmode == 2
    scanrate = 31;
end

end