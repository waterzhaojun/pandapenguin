function path = sbxPath(mouse, date, run, type, estimate)
%SBXPATH Gets the path to most types of sbx files. Requires run.

    path = [];
    
    % If date is an integer, convert to string
    if ~ischar(date), date = num2str(date); end

    % Load files from scanbox directories
    dirsf = sbxDir(mouse, date, run);
    dirs = dirsf.runs{1};
    
    searchdir = dirs.path;
    if isempty(searchdir), return; end
    if isempty(dir(searchdir)), return; end
    
    % Get path
    switch type
        case 'sbx'
            path = dirs.sbx;
        case 'clean'
            if ~isempty(dirs.sbx)
                [a, b, ~] = fileparts(dirs.sbx);
                cpath = [a '\' b '_clean.sbx'];
                if exist(cpath, 'file'), path = cpath; end
            end
        case 'info'
            if ~isempty(dirs.sbx), path = dirs.sbx(1:end - 4); end
        case 'quad'
            path = [dirs.path dirs.sbx_name '_quadrature.mat'];
        case 'stim'
            path = [dirs.path dirs.sbx_name '.f2p'];
        case 'simpcell'
            fname = sprintf('%s_%s_%03i.simpcell', mouse, date, run);
            path = [dirsf.date_mouse fname];
        case 'bhv'
            path = dirs.ml;
        case 'ephys'
            path = dirs.nidaq;
        case 'pupil'
            if ~isempty(dirs.sbx)
                checkpath = [dirs.sbx(1:end - 4) '_eye.mat']; 
                if exist(checkpath, 'file'), path = checkpath; end
            end
        case 'running'
            tmp = run_file_system();
            path = struct();
            path.folder = [dirs.path, tmp.folder];
            path.result = [dirs.path, tmp.folder, '\', tmp.resultPath];
        case 'bv'
            tmp = bv_file_system();
            path = struct();
            path.folderpath = correct_folderpath([correct_folderpath(dirs.path), tmp.folderpath]);
            path.layerfolderpath = {};

            flist = dir(path.folderpath);
            flist = flist(~ismember({flist.name},{'.','..'}));
            for i = 1:length(flist)
                path.layerfolderpath{i} = correct_folderpath([correct_folderpath(flist(i).folder), flist(i).name]);
            end
            path.resultpath = cellfun(@(x) [x, tmp.resultpath], path.layerfolderpath, 'UniformOutput', false);
        otherwise
            fs = dir(searchdir);
            
            for i=1:length(fs)
                [~, ~, ext] = fileparts(fs(i).name);
                if strcmp(ext, sprintf('.%s', type))
                    path = sprintf('%s%s', searchdir, fs(i).name);
                    %disp(sprintf('Found file at %s', path));
                end
            end
    end
    
    if nargin > 4 && estimate
        path = [dirs.base '.' type];
    end

end