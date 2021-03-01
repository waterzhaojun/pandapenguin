function train_bout_LCM_kernal(S, X, scanrate)

% S is the binary signal array. Like the binarized running signal. S shape should
% be m x 1;
% X is the recorded signal array. Like the blood vessel drr signal. It should before smooth treatment because it will be treated in this function. X
% should have the same shape as S.
% This two singal should have the same scanrate.
% This function refenced to https://pubmed.ncbi.nlm.nih.gov/25467301/

m = length(S);
n = 100;

% confirm direction =============================
if size(S, 1) == 1 && size(S, 2) > size(S, 1)
    S = S';
end

if size(X, 1) == 1 && size(X, 2) > size(X, 1)
    X = X';
end

% smooth signal =====================================
X = lowpass(medfilt1(X, floor(scanrate/3)), floor(scanrate/3), scanrate);

% format matrix =======================================
TX = [X; zeros(n,1)];

TS= [S; zeros(n,1)];
TS = toeplitz(TS,zeros(n+1,1));

H0 = [0; repmat(0.1, n, 1)];

fun = @(x) immse(TS * x, TX);


options = optimset('PlotFcns',@optimplotfval, 'Display','iter','MaxIter', 10000000000, 'TolFun', 1e-8, 'TolX', 1e-8);

H = fminsearch(fun,H, options);

storepath = [fileparts(matlab.desktop.editor.getActiveFilename), '\', 'LCM_kernal_paras.mat'];
save(storepath, 'H');





end