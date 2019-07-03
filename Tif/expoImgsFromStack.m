function expoImgsFromStack(path, neededFrms)

    img = loadTifStack(path);
    img = img(:,:,neededFrms);
    savePath = [path(1:end-4), '\neededFrms.tif'];
    writetiff(img, savePath);
            

end