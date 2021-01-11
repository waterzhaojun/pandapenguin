animal = 'WT0118';
date = '201125';
run = 6;

running_analysis(animal,date,run);
set_scanrate(animal,date,run,'running');
set_scanrate(animal,date,run,'bv');

folder = 'C:\2pdata\WT0118\201125_WT0118\201125_WT0118_run6\bv\1';
diameter_calculate_baseline(folder);

diameter_running_corAnalysis(animal, date, run);