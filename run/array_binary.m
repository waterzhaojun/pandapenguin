function S = array_binary(result)
% This function get binary array from result.
S = zeros(length(result.array),1);
for i = 1:length(result.bout)
    S(result.bout{i}.startidx:result.bout{i}.endidx) = 1;
end

end