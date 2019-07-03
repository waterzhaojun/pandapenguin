function mat2tif(path,color,autoContract)
    
    % set color = 1 if you want red pic;
    % set color = 2 if you want green pic;
    % set color = 3 if you want blue pic;
    if nargin<2, color = [1,2,3]; end
    if nargin<3, autoContract = 'N'; end
    
    % if need auto contract the img, set autoContract = 'Y';
    
    pic = load(path);
    pic = pic.img;
    if autoContract == 'Y'
        for i = 1:size(pic,3)
            pic(:,:,i) = imadjust(pic(:,:,i));
        end
    end
    pic = pic(:,:,color);
    
    imwrite(pic, [path(1:end-3), 'tif']);

end