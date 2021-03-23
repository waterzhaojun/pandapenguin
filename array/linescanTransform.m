function newmx = linescanTransform(mx, r, varargin)

% This function is to used in line scan matrix preparation, as described in
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4962871/
% The mx is a 2D input r is the timecourse. c is the scanbox scan of each
% timepoint (It is a line in the center of the view. c should be 796 pixal).

parser = inputParser;
addRequired(parser, 'mx'); % running bout signal array
addRequired(parser, 'r'); % response signal array
addParameter(parser, 'T', 4); % Each block is seperated to T small parts

parse(parser,mx, r, varargin{:});

T = parser.Results.T;

[f,c] = size(mx);

tgap = r / T;
f = floor((f-(T-1)*tgap)/r);

newmx = zeros(r*T,c,f);
for i = 1:T
    tmp = mx(1 + (i-1)*tgap : f*r + (i-1)*tgap, :)';
    tmp = reshape(tmp, c,r,f);
    tmp = permute(tmp, [2,1,3]);
    newmx( (i-1)*r + 1 : i*r, :, : )= tmp;
end
newmx = permute(newmx, [2,1,3]);
newmx = reshape(newmx, c,r,T*f);
newmx = permute(newmx, [2,1,3]);


end