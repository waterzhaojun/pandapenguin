function output = brightnessChangeTrend(valueTable, avoidPeriod)
    
% valueTable is a table read from csv. the first column is index column,
% representing the second. the second column is value column, giving the
% roi value. 
    valueTable_avoid = valueTable([1:avoidPeriod(1), avoidPeriod(2)+1:size(valueTable,1)],:);
    output = polyfit(valueTable_avoid(:,1),valueTable_avoid(:,2),1);
    
end
