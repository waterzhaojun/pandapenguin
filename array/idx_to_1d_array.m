function newarray = idx_to_1d_array(array, startIdx, endIdx, baselineLength, scanrate, varargin)
% This function is to extract a 1D array based on start idx, end
% idx, baseline length, scanrate. The array from start idx to end idx
% included both baseline and response period.
% baselineLength's unit is second. It suppose at the very beginning.
parser = inputParser;
addRequired(parser, 'array', @isnumeric );
addRequired(parser, 'startIdx', @isnumeric);
addRequired(parser, 'endIdx', @isnumeric); 
addRequired(parser, 'baselineLength', @isnumeric);
addRequired(parser, 'scanrate', @isnumeric);
addParameter(parser, 'norm', true, @islogical);
parse(parser, array, startIdx, endIdx, baselineLength, scanrate, varargin{:});

norm = parser.Results.norm;

newarray = array(startIdx:endIdx);
baselinearray = newarray(1:baselineLength * scanrate);
baseline = mean(baselinearray);

if norm
    newarray = newarray / baseline;
end





end