function root=rootpath(datasetname)
% I am afraid so far no function is using this way to extract path. They
% are still using sbxDir.

    cpu = getenv('computername');
    
    rootlist = containers.Map;
    
    if strcmp(cpu, 'DESKTOP-310AKSH')
        rootlist('2p') = 'C:\2pdata';
    elseif strcmp(cpu, 'W1BZXG430334')
        rootlist('2p') = 'D:\2P';
    end
    
    root = rootlist(datasetname);

end