function bout = findPosPiece(array, varargin)

% This function is to break a logical array to multiple continuous positive
% pieces. It is mainly to get the bout from a binary array.

parser = inputParser;
addRequired(parser, 'array', @islogical );
parse(parser, array, varargin{:});

bout = {};
flag = false;
for i = 1:length(array)
    if array(i) == 1 && ~flag
        tmp = struct();
        tmp.startidx = i;
        flag = true;
    elseif array(i) == 0 && flag
        tmp.endidx = i-1;
        bout{length(bout)+1} = tmp;
        tmp = struct();
        flag = false;
    end
end

end