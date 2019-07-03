function output = vector2str(vec, sepStr, startStr, endStr)
    
    if nargin <2, sepStr = ''; end
    if nargin <3, startStr = ''; end
    if nargin <4, endStr = ''; end
    
    if isnumeric(vec)
        vec = num2str(vec);
    end
    if length(vec)<2, output = strcat(startStr, vec, endStr); 
    else
        output = [startStr, num2str(vec(1))];
        for i = 2:length(vec)
            output = [output, sepStr, num2str(vec(i))];
            %strcat(output, sepStr, vec(i));
        end
        output = [output, endStr];
    end


end