function result=deshake(array)
% sometime the running wheel counts only because the shaking. This function is to remove the
% shaking.
flag = 0;
result = zeros(1, length(array));
for i = 1:length(array)
    if flag == 0
        if abs(array(i)) == 1 
            flag = array(i);
        end
        result(i) = array(i);
    else
        if abs(array(i)) > 1
            result(i) = array(i);
            flag = 0;
        elseif array(i) + flag == 0
            result(i) = 0;
            flag = array(i);
        else
            result(i) = array(i);
        end
    end
            
    
    
end


end