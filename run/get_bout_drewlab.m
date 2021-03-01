function [bout, secarray_treat, array_treat, restbout, restidx] = get_bout_drewlab(array, scanrate)


config = run_config();

array_treat = lowpass(array, 1, scanrate);  % change unit from m/s to cm/s
array_treat = abs(gradient(array_treat) * scanrate);
secarray_treat = bint1D(array_treat, floor(scanrate));

threshold = config.acceleration_threshold;
array_treat_binary = heaviside(array_treat - threshold);
array_treat_binary = positiveConcentrationFilter1D(...
    array_treat_binary,...
    floor(scanrate), ...
    config.positiveConcentrationThreshold...
);

array_treat_binary = logical(fillLogicHole(array_treat_binary, floor(scanrate)));
rest_binary = logical(1-array_treat_binary);

bout = findPosPiece(array_treat_binary);
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