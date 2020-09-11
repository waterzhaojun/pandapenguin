function mx = load_data(sourcetable, p)

[r,~] = size(sourcetable);
mx = zeros(abs(p.length),r);
for i = 1:r
    tmp = csvread(sourcetable{i,1});
    idx = uint32(sourcetable{i,2});
    if p.length > 0
        endidx = idx + p.length - 1;
        if endidx > length(tmp)
            error('endidx bigger than array length')
        else 
            endidx = uint32(endidx);
        end
        mx(:,i) = tmp(idx:endidx); %
    elseif p.length < 0
        startidx = idx +p.length + 1;
        if startidx <0
            error('startidx less than 0');
        else
            startidx = uint32(startidx);
        end
        mx(:,i) = tmp(startidx:idx);
    end
end

if isfield(p,'piece_length')
    remp = rem(abs(p.length), p.piece_length);
    if remp ~= 0
        mx = mx(1:end-remp,:)
    end
    mx = reshape(mx, p.piece_length, []);
end


end
