list = {
    'CGRP01','201118',1;'CGRP01','201118',2;...
    
    'CGRP02','201110',2;'CGRP02','201110',3;...
    'CGRP02','201117',1;'CGRP02','201117',2;'CGRP02','201117',3;'CGRP02','201117',4;...
    'CGRP02','201119',1;'CGRP02','201119',2;'CGRP02','201119',3;...
    
    'CGRP03','201109',1;'CGRP03','201109',2;...
    'CGRP03','201116',1;'CGRP03','201116',2;'CGRP03','201116',3;'CGRP03','201116',4;'CGRP03','201116',5;'CGRP03','201116',6;...
    'CGRP03','201118',1;'CGRP03','201118',2;'CGRP03','201118',3;'CGRP03','201118',4;'CGRP03','201118',5;'CGRP03','201118',6;'CGRP03','201118',7;...
    'CGRP03','201120',1;...
    
    'WT01','201111',1;'WT01','201111',2;'WT01','201111',3;'WT01','201111',4;...
    %'WT01','201117',1;...
    'WT01','201117',2;'WT01','201117',3;'WT01','201117',4;'WT01','201117',5;'WT01','201117',6;...
    'WT01','201119',1;'WT01','201119',2;'WT01','201119',3;'WT01','201119',4;'WT01','201119',5;...
    %'WT01','201124',1;'WT01','201124',2;'WT01','201124',3;'WT01','201124',4;...
    %'WT01','201125',1;'WT01','201125',2;...
    
    }

list = {
    'WT0118','201123',1;'WT0118','201123',2;'WT0118','201123',3;...
    'WT0118','201125',1;'WT0118','201125',2;'WT0118','201125',3;'WT0118','201125',4;'WT0118','201125',5;'WT0118','201125',6;...
    'WT0118','201201',1;'WT0118','201201',2;'WT0118','201201',3;'WT0118','201201',4;'WT0118','201201',5;'WT0118','201201',6;...
    'WT0118','201208',1;'WT0118','201208',2;'WT0118','201208',3;'WT0118','201208',4;'WT0118','201208',5;'WT0118','201208',6;'WT0118','201208',7;...
    
    'WT0119','201123',1;'WT0119','201123',2;'WT0119','201123',3;'WT0119','201123',4;...
    'WT0119','201125',1;'WT0119','201125',2;'WT0119','201125',3;'WT0119','201125',4;'WT0119','201125',5;'WT0119','201125',6;'WT0119','201125',7;...
    'WT0119','201201',1;'WT0119','201201',2;'WT0119','201201',3;'WT0119','201201',4;'WT0119','201201',5;...
    'WT0119','201208',1;'WT0119','201208',2;'WT0119','201208',3;'WT0119','201208',4;'WT0119','201208',5;'WT0119','201208',6;'WT0119','201208',7;'WT0119','201208',8;...
    
    'WT0120','201209',1;'WT0120','201209',2;'WT0120','201209',3;'WT0120','201209',4;'WT0120','201209',5;'WT0120','201209',6;'WT0120','201209',7;'WT0120','201209',8;'WT0120','201209',9;'WT0120','201209',10;...
}
for i = 1:size(list,1)
    disp(list{i,1});
    disp(list{i,2});
    disp(list{i,3});
    running_analysis(list{i,1}, list{i,2},list{i,3});
end