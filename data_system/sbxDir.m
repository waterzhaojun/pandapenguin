function dirs = sbxDir(mouse, date, runs, target)
% Set pathnames for scanbox for easy access

% If date is an integer, convert to string
if ~ischar(date), date = num2str(date); end

% If runs are not set, get all runs from the day
% If runs are set, check if runs is integer, if so, set to array
if nargin < 3
    runs = sbxRuns(mouse, date);
elseif isinteger(runs)
    runs = [runs];
end

% Set target to first run if unset
if nargin < 4
    target = runs(1);
end

base = sbxScanbase();
dirs.scan_base = base;

% Set the information outside of runs
dirs.mouse = sprintf('%s%s', base, mouse);
dirs.date_mouse = sbxMouseDateDir(mouse, date);

if isempty(dirs.date_mouse)
    msgID = 'SBXDIR:BadMouseNameDate';
    msg = 'Mouse and date not found.';
    baseException = MException(msgID, msg);
    throw(baseException);
end

if isempty(runs)
    msgID = 'SBXDIR:BadRun';
    msg = 'No runs found for mouse and date.';
    baseException = MException(msgID, msg);
    throw(baseException);
end

% Set the information per run
for i = 1:length(runs)
    % run.path path to run directory
    dirs.runs{i}.path = sbxRunDir(mouse, date, runs(i));
    
    % run.number is the integer number for the run
    dirs.runs{i}.number = runs(i);
    
    %run.date_mouse_run
    date_mouse_run = sbxRunDir(mouse, date, runs(i));
    slashes = strfind(date_mouse_run, '\');
    if isempty(slashes)
        dirs.runs{i}.date_mouse_run = [];
    else
        dirs.runs{i}.date_mouse_run = date_mouse_run(slashes(end-1)+1:end-1);
    end
    
    %run.sbx 2p file and filename without file extension or path
    sbxname = dir(sprintf('%s*.sbx', dirs.runs{i}.path));
    if ~isempty(sbxname)
        if length(sbxname) > 1
            minlen = -1;
            minpos = -1;
            for s = 1:length(sbxname)
                if minpos == -1 || length(sbxname(s).name) < minlen
                    minlen = length(sbxname(s).name);
                    minpos = s;
                end
            end
            sbxname = sbxname(minpos);
        end
        
        dirs.runs{i}.sbx = sprintf('%s%s', dirs.runs{i}.path, sbxname.name);
        dirs.runs{i}.sbx_name = sbxname.name(1:end-4);
    
        % run.base is the basename of files without any .
        dirs.runs{i}.base = sprintf('%s%s', dirs.runs{i}.path, sbxname.name(1:end-4));
    else
        dirs.runs{i}.sbx = [];
        dirs.runs{i}.sbx_name = [];
        dirs.runs{i}.base = [];
    end
    
    %run.nidaq and run.ephys (.ephys file from 2p or .nidaq .mat file)
    nidname = dir(sprintf('%s*.nidaq', dirs.runs{i}.path));
    ephname = dir(sprintf('%s*.ephys', dirs.runs{i}.path));
    if ~isempty(ephname)
        dirs.runs{i}.nidaq = sprintf('%s%s', dirs.runs{i}.path, ephname.name);
    elseif ~isempty(nidname)
        dirs.runs{i}.nidaq = sprintf('%s%s', dirs.runs{i}.path, nidname.name);
    else
        dirs.runs{i}.nidaq = [];
    end
    
    %runs.ptb (psychtoolbox .mat file coded as .ptb)
    ptbname = dir(sprintf('%s*.ptb', dirs.runs{i}.path));
    if ~isempty(ptbname)
        dirs.runs{i}.ptb = sprintf('%s%s', dirs.runs{i}.path, ptbname.name);
    else
        dirs.runs{i}.ptb = [];
    end
    
    %runs.ml (monkeylogic bhv file)
    mlname = dir(sprintf('%s*.bhv', dirs.runs{i}.path));
    if ~isempty(mlname)
        dirs.runs{i}.ml = sprintf('%s%s', dirs.runs{i}.path, mlname.name);
    else
        dirs.runs{i}.ml = [];
    end
    
    %runs.quad is running encoder, saved as .quad although not quadrature
    quadname = dir(sprintf('%s*quadrature*.mat', dirs.runs{i}.path));
    if ~isempty(quadname)
        dirs.runs{i}.quad = sprintf('%s%s', dirs.runs{i}.path, quadname.name);
    else
        dirs.runs{i}.quad = [];
    end
    
    %running folder 
    runsys = run_file_system();
    running = dir(sprintf('%s*%s', dirs.runs{i}.path, runsys.folder));
    if ~isempty(running)
        dirs.runs{i}.running = struct();
        dirs.runs{i}.running.folder = correct_folderpath([correct_folderpath(running.folder), running.name]);
        dirs.runs{i}.running.resultpath = [dirs.runs{i}.running.folder, runsys.resultPath];
        dirs.runs{i}.running.responsepath = [dirs.runs{i}.running.folder, runsys.responsePath];
    end
    
    %bv folder
    bvsys = bv_file_system();
    bvs = dir(sprintf('%s*%s', dirs.runs{i}.path, bvsys.folderpath));
    if ~isempty(bvs)
        dirs.runs{i}.bv = [];
        dirs.runs{i}.bv.folder = correct_folderpath([correct_folderpath(bvs.folder), bvs.name]);
        subbv = dir(dirs.runs{i}.bv.folder);
        subbv = subbv(~ismember({subbv.name},{'.','..'}));
        for sidx = 1:length(subbv)
            dirs.runs{i}.bv.layer{sidx}.folder = correct_folderpath([dirs.runs{i}.bv.folder, subbv(sidx).name]);
            dirs.runs{i}.bv.layer{sidx}.resultpath = [dirs.runs{i}.bv.layer{sidx}.folder, bvsys.resultpath];
            dirs.runs{i}.bv.layer{sidx}.movpath = [dirs.runs{i}.bv.layer{sidx}.folder, bvsys.movpath];
            dirs.runs{i}.bv.layer{sidx}.refpath = [dirs.runs{i}.bv.layer{sidx}.folder, bvsys.refpath];
            dirs.runs{i}.bv.layer{sidx}.ref_with_mask_path = [dirs.runs{i}.bv.layer{sidx}.folder, bvsys.ref_with_mask_path];
            dirs.runs{i}.bv.layer{sidx}.response_fig_path = [dirs.runs{i}.bv.layer{sidx}.folder, bvsys.response_fig_path];
            
        end
    end
    
    %runs.target is a target file for registration
    if isempty(target)
        dirs.runs{i}.target = [];
    else
        tarname = dir(sprintf('%s*.sbx', sbxRunDir(mouse, date, target)));
        if ~isempty(tarname)
            dirs.runs{i}.target = sprintf('%s%s', dirs.runs{i}.path, tarname.name);
        else
            dirs.runs{i}.target = [];
        end
    end
    
    % ================================================================
    % This following path is add by Jun. =============================
    % ================================================================
    
    % registration part.
    dirs.runs{i}.registration_ref = [dirs.runs{i}.base, '_registration_ref.tif'];
    
    % info.
    dirs.runs{i}.info = [dirs.runs{i}.base, '.mat'];
    
    %_pretreated.tif is a tif file pretreated with series of steps.
    pretreatedmov = dir(sprintf('%s*_pretreated.tif', dirs.runs{i}.path));
    if ~isempty(pretreatedmov)
        dirs.runs{i}.pretreatedmov = sprintf('%s%s', dirs.runs{i}.path, pretreatedmov.name);
    else
        dirs.runs{i}.pretreatedmov = [];
    end
    
    config = dir(sprintf('%sconfig.yml', dirs.runs{i}.path));
    if ~isempty(config)
        dirs.runs{i}.config = sprintf('%s%s', dirs.runs{i}.path, config.name);
    else
        dirs.runs{i}.config = [];
    end
    
    andyRegData = dir(sprintf('%s*_affine_tforms.mat', dirs.runs{i}.path));
    if ~isempty(andyRegData)
        dirs.runs{i}.andyRegData = sprintf('%s%s', dirs.runs{i}.path, andyRegData.name);
    else
        dirs.runs{i}.andyRegData = [];
    end
end



