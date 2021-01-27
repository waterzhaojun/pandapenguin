function [bout, array_filtered_bintAb, array_filtered, restbout] = get_bout(array, varargin)
parser = inputParser;
addRequired(parser, 'array', @isnumeric ); % This array must be deshaked.
addOptional(parser, 'scanrate', 15, @(x) isnumeric(x) && isscalar(x) && (x>0));
% addParameter(parser, 'gap', 2, @(x) isnumeric(x) && isscalar(x) && (x>0)); % how many seconds of gap to be considered as the end of the bout.
% addParameter(parser, 'duration', 2, @(x) isnumeric(x) && isscalar(x) && (x>0)); % how many seconds at least to be considered as a bout.
% addParameter(parser, 'threshold', 1, @(x) isnumeric(x) && isscalar(x) && (x>0)); % The threshold of blocks ran in one sec to be considered as running.

parse(parser,array, varargin{:});
scanrate = parser.Results.scanrate;
Nstate = 2;
emitGuess = [0,5;2,5];
transGuess = [0.9, 0.1; 0.5, 0.5];
magThreshold = 0.0041;

config = run_config();
direction_threshold = config.bout_direction_percent_threshold;
duration_threshold = config.bout_duration_threshold;
gap_threshold = config.bout_gap_duration_threshold;
distance_threshold = config.bout_sec_distance_threshold;

% recordlength = floor(length(array) / srate) * srate;
% array_sec = reshape(abs(array(1:recordlength)), srate, []);
% array_sec = sum(array_sec, 1);

gaussWidth = 1;
gaussSigma = 0.26;
gaussFilt = MakeGaussFilt( gaussWidth, 0, gaussSigma, scanrate );
array_filtered = abs(filtfilt( gaussFilt, 1, array ));  % I think it will be more reasonable to abs before bint
array_filtered_bintAb = bint1D(array_filtered, floor(scanrate));
array_filtered_bintAb(array_filtered_bintAb < magThreshold) = 0;

speedRange = 0:0.001:0.4; % <==== may need to change to a reasonable value.
speedDiscrete = imquantize( array_filtered_bintAb, speedRange );

% Need more study on this part
% ====================================================================
Nemit = numel(speedRange);
emitGuessPDF = nan(Nstate, Nemit);
for n = flip(1:Nstate)
    tempGauss = normpdf(speedRange, emitGuess(1,n), emitGuess(2,n) );
    emitGuessPDF(n,:) = tempGauss/sum(tempGauss);
end
[transEst, emitEst] = hmmtrain( speedDiscrete,  transGuess, emitGuessPDF, 'verbose',true ); 
% ====================================================================

state = hmmviterbi( speedDiscrete, transEst, emitEst )';
state = logical(2-state);
bout = findPosPiece(state);

% set some filter =====================================
% gap filter
lastbout = 0;
wantedIdx = [];
for i = 1:length(bout)
    if bout{i}.startidx - lastbout > gap_threshold
        wantedIdx = [wantedIdx, i];
    end
    lastbout = bout{i}.endidx;
end
    
% duration filter
tmpwantedIdx = [];
for i = 1:length(bout)
    if bout{i}.endidx - bout{i}.startidx + 1>duration_threshold
        tmpwantedIdx = [tmpwantedIdx, i];
    end
end
wantedIdx = intersect(wantedIdx, tmpwantedIdx);

bout = bout(wantedIdx);

% Now format and popular the characters ================================
for i = 1:length(bout)
    bout{i}.startsec = bout{i}.startidx;
    bout{i}.endsec = bout{i}.endidx;
    bout{i} = rmfield(bout{i},'startidx');
    bout{i} = rmfield(bout{i},'endidx');
end

% real start and end idx. Ideally this need to be the index at 15hz, I will
% pass this step to later.
for i = 1:length(bout)
    %bout{i}.startidx = get_real_idx(array_filtered, bout{i}.startsec, scanrate, magThreshold, 'start');
    %bout{i}.endidx = get_real_idx(array_filtered, bout{i}.endsec, scanrate, magThreshold, 'end');
    bout{i}.startidx = (bout{i}.startsec-1) * floor(scanrate) + 1;
    bout{i}.endidx = bout{i}.endsec * floor(scanrate);
    bout{i}.array = array_filtered(bout{i}.startidx : bout{i}.endidx);
    bout{i}.duration = length(bout{i}.array)/scanrate;
    bout{i}.speed = mean(bout{i}.array);   % I am using filtered data instead of original data.
    [bout{i}.maxspeed, acceleration_delay] = max(bout{i}.array);
    bout{i}.acceleration = bout{i}.maxspeed * scanrate / acceleration_delay; % Not sure this is accurate.
    bout{i}.acceleration_delay = acceleration_delay / scanrate;
    bout{i}.distance = bout{i}.speed * bout{i}.duration;
end


% restbout=============================================================
reststate = logical(1-state);
restbout = findPosPiece(reststate);

% set some filter for restbout =====================================
% gap filter
% lastrestbout = 0;
wantedIdx = [];
for i = 1:length(restbout)
    if restbout{i}.startidx - restbout{i}.endidx > sum(config.rest_period_ending_kickout)
        wantedIdx = [wantedIdx, i];
    end
    lastbout = bout{i}.endidx;
end

restbout = restbout(wantedIdx);

end