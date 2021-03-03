% suggest we have a response array
r = [0 0 2 3 5 5 5 4 2 1 1 0 3 4 4 5 2 0 0];

% suggest we have a running binary array
s = [0 0 1 1 1 1 1 1 0 0 0 0 1 1 0 1 0 0 0];

plot(r)
hold on
scatter(1:length(s), s)
hold off

% we build a HRF expontial model
amp = 4.47;
tao = 1.5413;
hrf = @(x) amp*exp(-x/tao);

plot(1:20, hrf(1:20));

%% step 1: The hrf model has a length n. 
% As I understand this n represent how long the model will effect.
n = length(r);%5;

% Based on this n, we do Toeplitz transformation to running binary s.
ts = [ones(length(s)+n,1), toeplitz([s'; zeros(n,1)], zeros(n,1))];


%% step 2: for each row, apply hrf model and get the sum. We use matrix multiplcation to do this step.


%% step 3: training
H0 = [0.1; 0.5];

fun = @(x) immse(ts * [0,x(1)*exp(-[1:5]/x(2))]' .* [ones(length(s),1); zeros(n,1)], [r';zeros(n,1)]);


options = optimset('PlotFcns',@optimplotfval, 'Display','iter','MaxIter', 10000000000, 'TolFun', 1e-8, 'TolX', 1e-8);

H = fminsearch(fun,H, options);

% 4.47, 1.54

%% Have a look trained result

est = ts * [0,hrf(1:n)]';
plot(est);
hold on
plot(r);
hold off