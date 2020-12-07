function newres = boutFilter(result, filt)
% filter is a string cell array
newres = result;
for i = 1:length(filt)
    idx = cellfun(@(x) eval(['x.',filt{i}]), newres.bout);
    newres.bout = newres.bout(idx);
end

end