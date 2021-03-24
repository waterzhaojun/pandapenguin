function HRF_plot(H, HRFPoints, varargin)

% This function is to plot the sample of HRF model by giving H parameters,
% points before the HRF model (If set to 0, there still have one zero point before the peak, which is the first element of HRF
% model. If set to n > 0, there will be n+1 zeros before the peak), 
% points produced by HRF model (start from one zero point and the following point from peak to fade away. So if you set it to n, there will be 1 zero, n from peak to end, totally n+1 points).

parser = inputParser;
addRequired(parser, 'H'); % HRF model parameters
addRequired(parser, 'HRFPoints'); % Like the diameter response signal array
addOptional(parser, 'preHRFPoints',0);
addOptional(parser, 'scanrate', 0);
parse(parser,H, HRFPoints, varargin{:});

preHRFPoints = parser.Results.preHRFPoints;
scanrate = parser.Results.scanrate;

samplex = -preHRFPoints:HRFPoints;
sampley = [zeros(1,preHRFPoints), HRF(H,HRFPoints)];

if scanrate > 0
    samplex = samplex / scanrate;
end

plot(samplex, sampley);
xline(0,':r',{['A: ', num2str(H(1))],['td: ', num2str(H(2))], ['tao: ', num2str(H(3))]});

yspan = max(sampley)-min(sampley);
ylim([min(sampley) - yspan*0.1, max(sampley) + yspan*0.1]);
if scanrate > 0
    xticks(floor(samplex(1)) : 1 : ceil(samplex(end)));
    xlabel('time (sec)');
end



end