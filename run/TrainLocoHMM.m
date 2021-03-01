function [transEst, emitEst, speedDiscreteExpt] = TrainLocoHMM(loco, varargin)
% Determine locomotive state using a Hidden Markov Model
IP = inputParser;
addRequired( IP, 'loco', @iscell )
addParameter( IP, 'int', 0.1, @isnumeric )
addParameter( IP, 'Nstate', 2, @isnumeric ) % Nstate = 2; % still/minor running, major running
addParameter( IP, 'stateName', {'Still','Running'}, @iscell )
addParameter( IP, 'transGuess', [0.9, 0.1; 0.5, 0.5], @isnumeric ) %transGuess = [0.9, 0.1; 0.5, 0.5];
addParameter( IP, 'emitGuess', [0,5;2,5], @isnumeric ) % row one: mean emission values for each state. row two: std of emission for each state (in cm/s, not bins)
addParameter( IP, 'show', false, @islogical )
addParameter( IP, 'saveDir', 'D:\MATLAB\LevyLab\', @ischar )
parse( IP, loco, varargin{:} ); 
speedInt = IP.Results.int;
Nstate = IP.Results.Nstate;
stateName = IP.Results.stateName; % stateName = {'Still','Running'};
transGuess = IP.Results.transGuess;
emitGuess = IP.Results.emitGuess;
show = IP.Results.show;
saveDir = IP.Results.saveDir;
Nexpt = numel(loco);

tic
% Discretize speed data (matlab can't handle continuous HMM) and pool across experiments/runs
fprintf('\nDiscretizing data');
speedRange = 0:speedInt:40; 
speedDiscreteExpt = cell(1,Nexpt);
for x = find(~cellfun(@isempty, loco))
    for r = find(~cellfun(@isempty, {loco{x}.quad})) %1%:
        loco{x}(r).speedDiscrete = imquantize( vertcat( loco{x}(r).speed ), speedRange ); % Down  speedDiscreteExpt 
    end
    speedDiscreteExpt{x} = vertcat(loco{x}.speedDiscrete); % pool runs
end 
speedDiscretePool = vertcat(speedDiscreteExpt{:})';  % pool experiments
toc

% Train HMM on pooled data
fprintf('\nTraining hidden Markov model');
Nemit = numel(speedRange);
emitGuessPDF = nan(Nstate, Nemit);
for n = flip(1:Nstate)
    tempGauss = normpdf(speedRange, emitGuess(1,n), emitGuess(2,n) );
    emitGuessPDF(n,:) = tempGauss/sum(tempGauss);
end
[transEst, emitEst] = hmmtrain( speedDiscretePool,  transGuess, emitGuessPDF, 'verbose',true );
toc

% Save the results
savePath = sprintf('%sLocoHMM_%istate', saveDir, Nstate);
fprintf('\nSaving %s', savePath);
save(savePath ); % ,  'transEst', 'emitEst', 'emitGuessPDF', 'transGuess'
toc
end

