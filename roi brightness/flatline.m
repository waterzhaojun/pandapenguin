function output = flatline(valueTable, brightnessTrend)
    
% valueTable is a table read from csv. the first column is index column,
% representing the second. the second column is value column, giving the
% roi value. 
    for i=1:size(valueTable, 1)
        valueTable(i,2) = valueTable(i,2)-(valueTable(i,1)*brightnessTrend(1)-brightnessTrend(2));
    end
    output = valueTable;

end
