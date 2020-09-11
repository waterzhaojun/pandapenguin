function plot_psd_histo(sigmx, freq, err, p)
% This function is to plot the power spectrum in a period of time. sigma
% and freq and err is the output of chronux mtspectrum function (s,f,err). sigmx is a 2D
% matrix. The 1st dimension is value of freq power, the 2nd dimension is
% number of trials or samples. freq is the frequency values (f) that
% produced by chronux. If err is not empty, this function will plot err
% bar. P is parameter struct that contains setting like which freq range is
% needed to plot, which front part need to exclude.

if nargin < 3; err = []; end
if nargin < 4; p = struct; end
p = load_default_parameters(p);
t = ones(1,length(freq));
if ~strcmp(p.freq_range, 'full')
    t = (freq>p.freq_range(1)) & (freq<p.freq_range(2));
end
if p.exclude_beginning_points > 0
    t(1:p.exclude_beginning_points) = 0;
end

t = logical(t);
sigmx = sigmx(t,:);
freq = freq(t);

if isempty(err)
    plot(freq, sigmx);
else
    if size(sigmx,2)>1
        error('To show error bar, sigmx 2nd dimension should be 1. ');
    elseif size(sigmx,1) ~= size(err,2)
        error('sigmx and err should have same 1st dimension length');
    elseif size(err,1) ~= 2
        error('err 1st dimension should be 2');
    else
        errneg = err(1,t);
        disp(size(errneg));
        errpos = err(2,t);
        errorbar(freq, sigmx, errneg, errpos);
    end
    

end



end

function p = load_default_parameters(para)

p = struct();
if isfield(para,'freq_range')
    p.freq_range = para.freq_range;
else
    p.freq_range = 'full';
end

if isfield(para,'exclude_beginning_points')
    p.exclude_beginning_points = para.exclude_beginning_points;
else
    p.exclude_beginning_points = 0;
end

end