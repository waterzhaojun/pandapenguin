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
addParameter(parser, 'linescanSampleSize', 0.05); % line scan T size. Means each frame represent how many seconds. Unit is sec.
addParameter(parser, 'linescanBlocksPerFrame', 4); % Seperate to how many blocks per frame.
addParameter(parser, 'excludeBeginningSec', 0); % remove the beginning several seconds.
parse(parser,animal,date,run,varargin{:});

%pmt = parser.Results.pmt;

pmt = parser.Results.pmt;
loadAll = parser.Results.loadAll;
bintSize = parser.Results.bintSize;
linescanSampleSize = parser.Results.linescanSampleSize;
linescanBlocksPerFrame = parser.Results.linescanBlocksPerFrame;
excludeBeginningSec = parser.Results.excludeBeginningSec;

disp(['load from pmt', num2str(pmt)]);

path = sbxPath(animal, date, run, 'sbx'); 
inf = sbxInfo(path, true);

if inf.scanmode == 1
    scanrate = 15.5;
elseif inf.scanmode == 2
    scanrate = 31;
end

mx = mxFromSbxPath(path);

if inf.nchan==1
    pmt = 1;
else
    pmt = pmt + 1;
end 

if excludeBeginningSec > 0, mx = mx(:,:,:,excludeBeginningSec*scanrate+1:end); end

if inf.area_line
    if ~loadAll, mx = mx(:,:,pmt,:); end

    % [r,c,ch,f] = size(mx);
    if bintSize > 1, mx = bintf(mx, bintSize); end
else
    % line scan. Right now I don't think it is useful to load all pmt data.
    % So just use one pmt data.
    mx = squeeze(mx(:,:,pmt,:));
    [r,c,f] = size(mx);
    mx = permute(mx, [2,1,3]);
    mx = reshape(mx, c,r*f)';
    Tr = round(linescanSampleSize * scanrate * inf.recordsPerBuffer / linescanBlocksPerFrame) * linescanBlocksPerFrame;
    mx = linescanTransform(mx, Tr);
end

mx = uint16(mx);

end