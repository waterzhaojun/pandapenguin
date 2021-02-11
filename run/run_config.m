function res = run_config()
res = struct();
%res.block_distance = 25 % The wheel block langth. Unit is mm.
res.bout_duration_threshold = 5; % how many seconds at least to be considered as a bout.
res.bout_gap_duration_threshold = 5; % how many seconds of gap to be considered as the end of the bout.
res.bout_sec_distance_threshold = 1; % The threshold of distance in one sec to be considered as running.
res.bout_direction_percent_threshold = 0.5; % The threshold of positive value in one bout's non zero array that define a forward running.
res.rest_period_length_threshold = 15; % When identify a rest period, the duration length of the period. Unit is sec.
res.rest_period_ending_kickout = [5,3]; % When you get a rest period, you need to kick out a period at two ending. If you set it [5,3], means kickout 5sec of the beginning, and kickout 3sec of the ending.
res.blockunit = 0.005; % every block is 20mm.
res.acceleration_threshold = 0.000001; %Not necessary if not use Drew lab method
res.speed_threshold = 0.01;
res.positiveConcentrationThreshold = 0.5;

end