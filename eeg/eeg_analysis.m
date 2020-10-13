function res = eeg_analysis(mx, p)

% mx is the 2D eeg matrix. The 1st dimension is signal. The 2nd dimension
% is the number of samples or trials.
% Right now I use chronux to analyze EEG data. The p is mainly match
% chronux parameters.

% The mx should be normalized before using this function.

res = struct();

params = p;
if ~isfield(params, 'tapers')
    disp('did not set taper, use [3,5]');
    params.tapers = [3,5];
end

if ~isfield(params, 'Fs')
    disp('did not set Fs, use 100');
    params.Fs = 100;
end

if ~isfield(params, 'fpass')
    disp('did not set fpass, use [0,50]');
    params.fpass = [0,50];
end
    
if isfield(params, 'err')
    params = rmfield(params, 'err')% Do not do error analysis now. [1, 0.05]; % 
end

% I don't think ratio is a good idea to average. If use ratio, one kind of
% wave increase means other kinds of wave decrease, which dosen't make
% sense. So I will stick to analyze power.
params.trialave = 0; 

[s,f] = mtspectrumc( mx, params );
res.spectrum.s = s; % power spectrum signal
res.spectrum.avg = mean(s, 2);
res.f = f; % frequency range

deltaf = f(2:end)-f(1:end-1);
deltaf = [deltaf, deltaf(end)];
powers = (s.^2) .* deltaf';

% define the wave types
gamma_range = (f>=30) & (f<50);
beta_range = (f>=13) & (f<30);
alpha_range = (f>=8) & (f<13);
theta_range = (f>=4) & (f<8);
delta_range = (f>=0.5) & (f<4);

res.psd.array = [sum(powers(delta_range, :),1); sum(powers(theta_range, :),1); sum(powers(alpha_range, :),1); sum(powers(beta_range, :),1); sum(powers(gamma_range, :),1)];
res.psd.avg = mean(res.psd.array,2);


res.wave_ratio_array = [res.delta.array; res.theta.array; res.alpha.array; res.beta.array; res.gamma.array]';
res.wave_ratio_array_avg = [res.delta.avg; res.theta.avg; res.alpha.avg; res.beta.avg; res.gamma.avg]';



end