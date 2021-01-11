function df = combine_data_from_csv_list(listfilepath, varargin)
% This function is to load a csv file that contains a list of result csv
% files to a table. It also produce a csv file that contains this data
% at the same folder of the list csv file.
%df = csvread(listfilepath);
parser = inputParser;
addRequired(parser, 'listfilepath', @ischar );
addOptional(parser, 'filetype', 'mat');
parse(parser,path, varargin{:});

filetype = parser.Results.filetype;

filelist = {};
fid = fopen(listfilepath,'r');
tline = fgetl(fid);
while ischar(tline)
    i = length(filelist) + 1;
    filelist{i} = tline;
    tline = fgetl(fid);
end
fclose(fid);

for i = 1:length(filelist)
    if strcmp(filetype, 'mat')
        tmp = load(filelist{i});
        tmp = tmp.result;
        if i == 1
            df = tmp;
        else
            df = [df,tmp];
        end
        
    elseif strcmp(filetype, 'csv')
        tmp = readtable(filelist{i});
        if i == 1
            df = tmp;
        else
            df = [df;tmp];
        end
    end
    
    
    
end

if strcmp(filetype, 'csv')
    outputpath = [listfilepath(1:end-4), '_final.csv'];
    writetable(df, outputpath);
end


end