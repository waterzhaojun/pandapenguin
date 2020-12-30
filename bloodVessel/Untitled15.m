options.format = 'html';
options.evalCode = true;
options.stylesheet = 'publish_no_code.xsl';
options.showCode = false;
%options.codeToEvaluate = filename; % filename is the name of the file which is to be published
%publish('nb_bv_running_corr.m',options);
animal = 'CGRP03'
date = '201109'
run = 3
running_analysis(animal, date, run)
folder = 'D:\2P\CGRP03\201109_CGRP03\201109_CGRP03_run3\bv\6to7';
diameter_calculate_baseline(folder)