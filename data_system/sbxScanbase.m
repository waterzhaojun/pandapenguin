function base = sbxScanbase()

cpu = getenv('computername');

if strcmp(cpu, 'DESKTOP-310AKSH')
    base = 'C:\2pdata\';
elseif strcmp(cpu, 'W1BZXG430334')
    base = 'D:\2P\';
elseif strcmp(cpu, 'W1BZXG7588AF')
    base = 'D:\2photon\';
end

end

