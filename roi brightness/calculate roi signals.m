brightTrend = brightnessChangeTrend(table2array(CSDValuesbg), [100, 300]);

CSDastrocyte1 = flatline(table2array(CSDValuesastrocyte1), brightTrend);
CSDValuesbgarray = flatline(table2array(CSDValuesbg), brightTrend);

plot(CSDastrocyte1(:,2));
plot(CSDValuesbgarray(:,2));

%========================================================================
%the above treatment is use back ground changes as reference, but this
%changes is different to astrocyte's change rate. the output is still
%slopy.

CSDastrocyte1 = flatline(table2array(CSDValuesastrocyte1), brightnessChangeTrend(table2array(CSDValuesastrocyte1), [100, 500]));
CSDastrocyte2 = flatline(table2array(CSDValuesastrocyte2), brightnessChangeTrend(table2array(CSDValuesastrocyte2), [100, 500]));
CSDastrocyte3 = flatline(table2array(CSDValuesastrocyte3), brightnessChangeTrend(table2array(CSDValuesastrocyte3), [100, 500]));
CSDneuron1 = flatline(table2array(CSDValuesneuron1), brightnessChangeTrend(table2array(CSDValuesneuron1), [100, 500]));
CSDneuron2 = flatline(table2array(CSDValuesneuron2), brightnessChangeTrend(table2array(CSDValuesneuron2), [100, 500]));



plot(CSDastrocyte2(:,2));