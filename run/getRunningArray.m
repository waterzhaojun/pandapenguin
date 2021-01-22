function array = getRunningArray(path, varargin)
% This function is to load running data from the quad file.
parser = inputParser;
addRequired(parser, 'path', @ischar );
addParameter(parser, 'bint', 1, @(x) isnumeric(x) && isscalar(x) && (x>0));
addParameter(parser, 'deshake', false, @islogical); % Deprecated
addParameter(parser, 'absvalue', 0, @islogical); %Usually I think keep negative value is necessary. If you want just abs value, set it to 1;
parse(parser,path, varargin{:});

array = load(path);
array = double(array.quad_data);
array = gradient(array);%array(1:end) - [0,array(1:end-1)];

if parser.Results.deshake
    array = deshake(array);
end

if parser.Results.absvalue
    array = abs(array);

if parser.Results.bint > 1
%     tmp = floor(length(array) / parser.Results.bint) * parser.Results.bint;
%     array = reshape(array(1:tmp), parser.Results.bint, []);
%     array = sum(array, 1);
    array = bint1D(array,bint,'method','sum');
end



end