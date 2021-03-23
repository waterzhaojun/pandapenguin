function [row,column,value] = max_2D(A)

% This function is to get the max index of 2D array

[y,~] = max(A);
[value,column] = max(y);
[~,row] = max(A(:,column));

end