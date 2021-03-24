function [H, coeff] = HRF_train(stimulate_binary_array, response_array, scanrate, varargin)

% S is the binary signal array. Like the binarized running signal. S shape should
% be m x 1;
% X is the recorded signal array. Like the blood vessel drr signal. It should before smooth treatment because it will be treated in this function. X
% should have the same shape as S.
% This two singal should have the same scanrate.
% This function refenced to https://pubmed.ncbi.nlm.nih.gov/25467301/

% This function is a replacement of train_HRF_model.m. It uses a HRF.m as
% the model function.

parser = inputParser;
addRequired(parser, 'stimulate_binary_array', @isnumeric ); % Like binarized running array
addRequired(parser, 'response_array', @isnumeric ); % Like the diameter response signal array
addRequired(parser, 'scanrate');
addParameter(parser, 'modelLength', 200); % the HRF model length. Unit is sec. Means this stimulation effect can't more than this long seconds.
addParameter(parser, 'beginningTruncateSec', 10); % truncate the beginning several seconds of the arrays, As the beginning of the recording always noisy.
addParameter(parser, 'bound', {[-20,0,0.5],[120,20,150]}); % Define A, Td, tao can't be trained out of these ranges.
addParameter(parser, 'initValue', [0.1, 0.1, 0.1]); % Initial A, Td, tao values.
addParameter(parser, 'showResultPlot', true); % Whether show the trained result.
addParameter(parser, 'runresult', nan); % This variable is specific for running data. It is to ask if we want to plot the running result in the result.

parse(parser,stimulate_binary_array, response_array, scanrate, varargin{:});

n = parser.Results.modelLength * scanrate;
beginningTruncateSec = parser.Results.beginningTruncateSec;
bound = parser.Results.bound;
bound{1}(2) = bound{1}(2)*scanrate;
bound{1}(3) = bound{1}(3)*scanrate;
bound{2}(2) = bound{2}(2)*scanrate;
bound{2}(3) = bound{2}(3)*scanrate;
initValue = parser.Results.initValue;
showResultPlot = parser.Results.showResultPlot;
runresult = parser.Results.runresult; % give the run result here. If yes, plot running in the output fig.

% Training part ========================================================
% truncate the data
S = stimulate_binary_array(beginningTruncateSec * scanrate + 1 : end);
X = response_array(beginningTruncateSec * scanrate + 1 : end);

% confirm direction
if size(S, 1) == 1 && size(S, 2) > size(S, 1)
    S = S';
end

if size(X, 1) == 1 && size(X, 2) > size(X, 1)
    X = X';
end

% smooth signal. I am not sure the paper suggested smooth paras is good for us ============
%X = lowpass(medfilt1(X, floor(scanrate/3)), floor(scanrate/3), scanrate);
X = lowpass(medfilt1(X, 5), 3, scanrate);

% format matrix 
TX = [X; zeros(n,1)];

TS = [S; zeros(n,1)];
TS = toeplitz(TS,zeros(n,1));
TS = [ones(length(TS),1), TS];

Trunning_binary = toeplitz(stimulate_binary_array, zeros(n,1));
Trunning_binary = [ones(size(Trunning_binary, 1),1), Trunning_binary]; % This is for validate.

% HRF model
%HRF = @(x) [0,x(1)*exp(-([1:n] - x(2)) / x(3))] .*[0, floor(heaviside([1:n]-x(2)))];
fun = @(x) immse(TS * HRF(x, n)', TX);

%'PlotFcns',@optimplotfval, ...
options = optimset('MaxIter', 10000000000, 'TolFun', 1e-8, 'TolX', 1e-8);

flag = true;
coeff_list = [1,1];

while flag
    [H,fval] = fminsearchbnd(fun, initValue, bound{1}, bound{2}, options);
    est = Trunning_binary * HRF(H, n)';
    coeff = corrcoef(est, response_array);
    coeff = coeff(1,2);
    disp(sprintf('Corrcoef: %d', coeff));
    coeff_list = [coeff_list, coeff];
    coeff_list = coeff_list(max(1,length(coeff_list)-3):end);
    if std(coeff_list) == 0
        flag = false;
    else
        initValue = H;
    end
    
end

H(2) = H(2)/scanrate;
H(3) = H(3)/scanrate;

if showResultPlot
    runidx = find(stimulate_binary_array == 1);
    bottomValue = min(response_array) - (max(response_array) - min(response_array))*0.1;
    plot(response_array);
    hold on
    plot(est, 'LineWidth',2);
    if strcmp(class(runresult), 'struct')
        plot_running(runresult);
    else
        scatter(runidx, repmat(bottomValue,length(runidx),1),'filled');
    end
    hold off
end


end