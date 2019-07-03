function out = bint_1d(data, bin, method)
%BINT Bin a movie along the third dimension with factor bin

    if nargin < 2, out = data; return; end
    if bin < 2, out = data; return; end
    
    if nargin < 3, method = 'mean'; end

    t = length(data);
    t = floor(t/bin)*bin;
    out = data(1:t);
    
    out = reshape(out, bin, []);
    
    if strcmp(method, 'mean')
        out = mean(out, 1);
    elseif strcmp(method, 'sum')
        out = sum(out, 1);
    end
end