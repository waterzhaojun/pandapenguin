function [newdf,keepbout, outbout, keepboutID, outboutID] = bout_filter_median(df)

keepbout = [];
outbout = [];
for b = 1:length(df)
   if median(df(b).baselineArray) < restmean + reststd
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