function res = eeg_analysis(mx, p)

% mx is the 2D eeg matrix. The 1st dimension is signal. The 2nd dimension
% is the number of samples or trials.
% Right now I use chronux to analyze EEG data. The p is mainly match
% chronux parameters.

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
    
if ~isfield(params, 'err')
    params.err = [1, 0.05]; % should do error analysis
end

params.trialave = 1; %force to calculate average.

[s,f,err] = mtspectrumc( mx, params );
res = struct();
res.s = s; % power spectrum signal
res.f = f; % frequency range

gamma_range = (f>=30) & (f<50);
res.gamma = sum(s(gamma_range).^2);

beta_range = (f>=13) & (f<30);
res.beta = sum(s(beta_range).^2);

alpha_range = (f>=8) & (f<13);
res.alpha = sum(s(alpha_range).^2);

theta_range = (f>=4) & (f<8);
res.theta = sum(s(theta_range).^2);

delta_range = (f>=0.5) & (f<4);
res.delta = sum(s(delta_range).^2);

res.wave_type_array = [


end