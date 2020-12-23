function diameter_running_analysis(animal, date, run)
% This function is to do diameter running correlation analysis. This is not
% a necessary step for initial diameter analysis process.
runpath = sbxPath(animal, date, run, 'running');
runpath = runpath.result;

bvpath = sbxPath(animal, date, run, 'bv');

df = correlation_table_running_bv({animal, date, run;});


end


explist = {animal, date, run;};