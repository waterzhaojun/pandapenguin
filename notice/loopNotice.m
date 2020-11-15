function loopNotice(i,f,varargin)

parser = inputParser;
addRequired(parser, 'i', @(x) isnumeric(x) && isscalar(x) && (x > 0));
addRequired(parser, 'f', @(x) isnumeric(x) && isscalar(x) && (x > 0));
addParameter(parser, 'times', 20, @(x) isnumeric(x) && isscalar(x) && (x > 0));
parse(parser,i, f, varargin{:});

gap = floor(f/parser.Results.times);
if rem(i, gap) == 0
    disp([num2str(i), ' of ', num2str(f), ' is done.']);
end


end