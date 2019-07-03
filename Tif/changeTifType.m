function output = changeTifType(picArray)

    maxValue = max(max(picArray));
    if maxValue <=1
        output = double(picArray);
    elseif maxValue<=255 & maxValue>1
        output = uint8(picArray);
    elseif maxValue>255 & maxValue<=65535;
        output = uint16(picArray);
    end

end