function diameter(path)

    % step 1: draw roi
    % path = 'C:\2pdata\DL128\181009_DL128\181009_DL128_run2\DL128_181009_001_redChl.tif';

    bf_mov = loadTifStack(path);
    % bf_mov = bf_mov*10; % adjust this parameter based on different label brightness
    pic_ref = max(bf_mov(:,:,:), [], 3);
    pic_ref = uint8(pic_ref);

    % when draw the rectangle, should draw clockwise with starting from left
    % side of vessel. Should as vertical to vessel as possible.
    [BW, xi, yi] = roipoly(pic_ref); % xi = col, yi = row
    BW = double(BW);

    BW(uint16(yi(1)), uint16(xi(1))) = 11;
    BW(uint16(yi(2)), uint16(xi(2))) = 22;
    BW(uint16(yi(3)), uint16(xi(3))) = 33;

    % step 2: rotate the image and crop the edge ----------------------------
    xm = xi(2)-xi(1);
    ym = yi(2)-yi(1);
    angel = 90-asin(xm/sqrt(xm^2+ym^2))*180/pi;
    bf_mov_rotated = imrotate(bf_mov,angel);
    BW_rotated = imrotate(BW, angel);
    [p1r,p1c]=find(BW_rotated == 11);
    [p2r,p2c]=find(BW_rotated == 22);
    [p3r,p3c]=find(BW_rotated == 33);
    bf_corp = bf_mov_rotated(min(p1r, p2r):p3r, p1c:max(p2c, p3c),:);
    imshow(bf_corp(:,:,1)/60);
    % to adjust angel, but if you do the right track sequence, it is not
    % necessary
    %line1 = std(double(bf_mov(:,floor(end/2),1)));
    %line2 = std(double(bf_mov(floor(end/2),:,1)));
    %if(line1 > line2)
    %    bf_mov = permute(bf_mov,[2,1,3]);
    %end

    % step 3: for each frame, calculate diameter------------------------------
    output_topo = [];
    output_tl = [];
    for i = 1:size(bf_corp,3)
        output_topo(:,i) = mean(bf_corp(:,:,i), 1);
        output_tl = [output_tl,findEdge(output_topo(:,i))];
    end

    output_topo = uint8(2* output_topo);
    output_tl = smooth(output_tl, 15);
    % output the data to local folder
    [foldername,filename, extname] = fileparts(path);
    output_filename = strcat(foldername, '\bf_diamater.csv');
    csvwrite(output_filename,output_tl);
    imwrite(imadjust(pic_ref),strcat(foldername, '\ref.jpg'))
    imwrite(imadjust(BW), strcat(foldername, '\ref_mast.jpg'))

end