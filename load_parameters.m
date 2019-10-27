function p = load_parameters(animalid, date, run, configPath, pmt, copy_config_file)
    % This function is only used to pretreat.
    % To make sure copy config.yml to your treat folder, you need both set 
    % copy_config_file to 1 and give a path instead of the same folder. 
    
    p = {};
    p.animal = animalid;
    p.date = date;
    p.run = run;
    
    if nargin<6, copy_config_file = 0; end
    if nargin<5, pmt = 0; end
    
    p.pmt = pmt;
    path = sbxPath(animalid, date, run, 'sbx'); 
    inf = sbxInfo(path, true);
    tmp = sbxDir(animalid, date, run);
    p.dirname = tmp.runs{1}.path;
    p.basicname = strtok(path, '.');
    p.config_path = [p.dirname, 'config.yml'];
    
    
    if nargin<4, configPath = ''; end
    
    
    if copy_config_file & ~strcmp(configPath, '')
        copyfile(configPath, p.dirname); 
    end
    
    p.config = ReadYaml(p.config_path);

    % the following part need to define based on each person's code.
    
    p.refname = [p.basicname, p.config.registration_ref_ext, '.tif'];
    p.pretreated_mov = [p.basicname, '_pretreated.tif'];
    p.scanrate = 15;
    p.keep_frames = floor((inf.max_idx+1)/(inf.scanmode*15.5)/60)*60*floor(inf.scanmode*15.5);
    p.keep_frames_start = floor((inf.max_idx+1-p.keep_frames)/2/(inf.volscan+1))*(inf.volscan+1)+1;
    
    p.downsample_t = floor(inf.scanmode * 15.5  / p.config.output_fq);

end