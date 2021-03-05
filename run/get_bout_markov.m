function [bout, secarray_treat, array_treat, restbout, restidx] = get_bout_markov(array, scanrate, parafilepath)


config = run_config();

gaussWidth = 1;
gaussSigma = 0.26;
gaussFilt = MakeGaussFilt( gaussWidth, 0, gaussSigma, scanrate );
array_treat = abs(filtfilt( gaussFilt, 1, array ));  % change unit from m/s to cm/s
secarray_treat = bint1D(array_treat, floor(scanrate));


Nstate = 2;

%loadPath = 'C:\Users\Levylab\jun\pandapenguin\run\LocoHMM_2state.mat';
load(parafilepath, 'speedRange', 'transEst', 'transGuess', 'emitEst', 'emitGuessPDF', 'Nemit', 'stateName') 

%speedDiscrete = imquantize( vertcat( array ), speedRange );
state = hmmviterbi( imquantize( vertcat( 100 * array_treat ), speedRange )', transEst, emitEst )';
state = state - 1;
% stateBinary = false( size(state, 1), Nstate );
% for n = 1:Nstate
%     stateBinary(:,n) = state == n; 
% end  
rest_binary = logical(1-state);
bout = findPosPiece(logical(state));
restbout = findPosPiece(rest_binary);

% format bout ======================================
for i = 1:length(bout)
    bout{i}.array = array(bout{i}.startidx : bout{i}.endidx);
    bout{i}.array_treat = array_treat(bout{i}.startidx : bout{i}.endidx);
    
    % startsec and endsec can't be used as idx for bv idx as even bv is 15
    % layers, its scanrate is 1.03, not 1. So startsec, endsec,
    % secarray_treat is just for view, can't for analysis.
    bout{i}.startsec = translateIdx(bout{i}.startidx, scanrate, scanrate/floor(scanrate)); 
    bout{i}.endsec = min(length(secarray_treat), translateIdx(bout{i}.endidx, scanrate, scanrate/floor(scanrate)));
    bout{i}.secarray_treat = secarray_treat(bout{i}.startsec : bout{i}.endsec);
    
    bout{i}.duration = (bout{i}.endidx - bout{i}.startidx + 1) * scanrate;
    bout{i}.speed = mean(bout{i}.array_treat);
    bout{i}.distance = bout{i}.duration * bout{i}.speed;
    [bout{i}.maxspeed, tmp] = max(bout{i}.array_treat);
    bout{i}.maxspeed_delay = tmp/scanrate;
    bout{i}.acceleration = bout{i}.maxspeed / bout{i}.maxspeed_delay;
end

%==================================================================
% add some filter for rest bout ===================================
%==================================================================

wantedIdx = [];
restidx = [];
for i = 1:length(restbout)
    if restbout{i}.endidx - restbout{i}.startidx >= config.rest_period_length_threshold*scanrate
        wantedIdx = [wantedIdx, i];
        restbout{i}.startidx = restbout{i}.startidx + config.rest_period_ending_kickout(1) * floor(scanrate);
        restbout{i}.endidx = restbout{i}.endidx - config.rest_period_ending_kickout(2) * floor(scanrate);
        restidx = [restidx, restbout{i}.startidx : restbout{i}.endidx];
    end
end
restbout = restbout(wantedIdx);
% Same as bout, startsec and endsec is just for plot view, can't used for
% analysis
for i = 1:length(restbout)
    restbout{i}.startsec = translateIdx(restbout{i}.startidx, scanrate, scanrate/floor(scanrate));
    restbout{i}.endsec = translateIdx(restbout{i}.endidx, scanrate, scanrate/floor(scanrate));
end

end