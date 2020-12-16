function res = run_config()
res = struct();
res.bout_duration_threshold = 2; % how many seconds at least to be considered as a bout.
res.bout_gap_duration_threshold = 5; % how many seconds of gap to be considered as the end of the bout.
res.bout_sec_distance_threshold = 1; % The threshold of distance in one sec to be considered as running.
res.bout_direction_percent_threshold = 0.5; % The threshold of positive value in one bout's non zero array that define a forward running.



end