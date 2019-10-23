function config = load_config(path)

    %[filepath, name, ext] = fileparts(path);
    %if strcmp(ext, '.json')
    %    disp(filepath);
   %    fid =fopen(path);
    %    raw = fread(fid, inf);
   %     str = char(raw');
   %     fclose(fid);
   %     config = jsondecode(str);
  %  elseif strcmp(ext, '.yml')
        config = ReadYaml(path);
  %  end

end