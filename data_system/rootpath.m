function root=rootpath(datasetname)

    cpu = getenv('computername');
    
    rootlist = containers.Map;
    
    if strcmp(cpu, 'DESKTOP-310AKSH')
        rootlist('2p') = 'C:\2pdata';
    end
    
    root = rootlist(datasetname);

end