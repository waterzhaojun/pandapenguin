function create_ref_pic(path, redchannel, refpic)

    finalmap = [];
    finalmap(:,:,1) = imadjust(double(redchannel) / double(intmax(class(redchannel))));
    finalmap(:,:,2) = 0;
    finalmap(:,:,3) = refpic;
    imwrite(finalmap, path);
    