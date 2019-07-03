function cs = xy3DValue(array, xy)

    nf = size(array, 3);
    nxy = size(xy,1);
    cs = uint16(zeros(nf, 1));
    
    for i = 1:nxy
        cs = cs + (reshape(array(xy(i,1), xy(i,2), :), [], 1)-cs)/i;
    end
   % for i = 1:nxy
   %     cs = cs + reshape(array(xy(i,1), xy(i,2), :), [], 1);
   % end
end