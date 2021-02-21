function [newdf,keepbout, outbout, keepboutID, outboutID] = bout_filter_percentage(df)

keepbout = [];
outbout = [];
config = run_config();
for b = 1:length(df)
   sum(df(b).runningbaselineArray < config.speed_threshold) / length(df(b).runningbaselineArray)
   if sum(df(b).runningbaselineArray < config.speed_threshold) / length(df(b).runningbaselineArray) > 0.5%restmean + reststd
       keepbout = [keepbout, b];
   else
       outbout = [outbout, b];
   end
end

disp(sprintf('keep %d bouts', length(keepbout)));
disp(sprintf('remove %d bouts', length(outbout)));
newdf = df(keepbout);

keepboutID = unique({df(keepbout).runningboutID});
outboutID = unique({df(outbout).runningboutID});


end