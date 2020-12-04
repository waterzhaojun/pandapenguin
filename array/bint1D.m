function output = bint1D(vec, bin, varargin)
% this function bin the 1D vector with bin parameter
parser = inputParser;
addRequired(parser, 'vec', @isnumeric );
addRequired(parser, 'bin', @isnumeric );
addParameter(parser, 'method', 'mean');
parse(parser,vec,bin,varargin{:});

    vecLen = floor(length(vec)/bin);
    output = reshape(vec(1:(bin*vecLen)), [bin, vecLen]);
    if strcmp(parser.Results.method, 'mean')
        output = mean(output, 1);
    elseif strcmp(parser.Results.method, 'sum')
        output = sum(output, 1);
    end

end