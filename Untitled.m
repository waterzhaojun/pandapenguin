animal = 'WT0118';
date = '201208';
run = 1;

running_analysis(animal,date,run);
set_scanrate(animal,date,run,'running');
set_scanrate(animal,date,run,'bv');

folder = 'C:\2pdata\WT0118\201208_WT0118\201208_WT0118_run1\bv\1';
diameter_calculate_baseline(folder);

diameter_running_corAnalysis(animal, date, run);