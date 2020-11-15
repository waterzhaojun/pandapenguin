function mx = mxFromSbxInfo(animal,date,run,pmt, varargin)
% This function is to get the matrix from exp info. It will output a 4D
% matrix.
% If you don't set pmt, it will set pmt=0 as default even you have multiple pmt recorded.
% If you have multiple pmt recorded, and you need to load all pmts, use
% 'loadAll', 1. Once you set it, it will ignore the pmt setting.
% If you want to bint your data along 4th dimension, set 'bintSize' to a >1
% integar.

parser = inputParser;
addRequired(parser, 'animal', @ischar );
addRequired(parser, 'date', @ischar);
addRequired(parser, 'run', @(x) isnumeric(x) && isscalar(x) && (x>0));
addOptional(parser, 'pmt', 0, @(x) isnumeric(x) && isscalar(x) && (x>=0) && (x<=2));
addParameter(parser, 'loadAll', 0, @islogical);
addParameter(parser, 'bintSize', 1, @(x) isnumeric(x) && isscalar(x) && (x>0));
parse(parser,animal,date,run,pmt,varargin{:});

%pmt = parser.Results.pmt;
disp(['load from pmt', num2str(pmt)]);
loadAll = parser.Results.loadAll;
bintSize = parser.Results.bintSize;

path = sbxPath(animal, date, run, 'sbx'); 
inf = sbxInfo(path, true);
mx = mxFromSbxPath(path);

if inf.nchan==1
    pmt = 1;
else
    pmt = pmt + 1;
end 

if ~loadAll, mx = mx(:,:,pmt,:); end

[r,c,ch,f] = size(mx);
if bintSize > 1, mx = bintf(mx, bintSize); end

end