function newmx = linescanTransform(mx, r, varargin)

parser = inputParser;
addRequired(parser, 'mx'); % running bout signal array
addRequired(parser, 'r'); % response signal array
addParameter(parser, 'T', 4); % Each block is seperated to T small parts

parse(parser,mx, r, varargin{:});

T = parser.Results.T;

[f,c] = size(mx);

%f = round(f / T) * T;

tgap = r / T;
f = floor((f-3*tgap)/r);

newmx = zeros(r*T,c,f);
for i = 1:T
    tmp = mx(1 + 0*tgap : f*r + 0*tgap, :)';
    tmp = reshape(tmp, c,r,f);
    tmp = permute(tmp, [2,1,3]);
    newmx( (i-1)*tgap + 1 : (i-1)*tgap + r, :, : )= tmp;
end
% mx2 = reshape(mx(0*r + 1*tgap + 1 : f*r + 1*tgap, :)', c,r,f)';
% mx3 = reshape(mx(0*r + 2*tgap + 1 : f*r + 2*tgap, :)', c,r,f)';
% mx4 = reshape(mx(0*r + 3*tgap + 1 : f*r + 3*tgap, :)', c,r,f)';


end