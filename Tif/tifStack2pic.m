function tifStack2pic(path, method, startFrame, endFrame, gain)

% I write this function to overlay AQuA treated tif to single tif.
% But this function can also used to other situations.


mx = loadTiffStack_slow(path);
[r,c,ch,f] = size(mx);

if nargin < 5, gain = 5; end
if nargin < 4, endFrame = f; end
if nargin < 3, startFrame = 1; end
if nargin < 2, method = 'avg'; end

savepath = split(path,'.');
savepath = [savepath{1}, '_overlay.tif'];

tinymx = mx(:,:,:,startFrame:endFrame);

if strcmp(method, 'avg')
    pic = mean(tinymx, 4);
elseif strcmp(method, 'max')
    pic = max(tinymx, [], 4);
end

if ch > 1
    pic = pic * 255;
end

if ch>1
    mask1 = (pic(:,:,1) ./ pic(:,:,2) == 1);
    mask2 = (pic(:,:,1) ./ pic(:,:,3) == 1);
    mask3 = (pic(:,:,2) ./ pic(:,:,3) == 1);
    mask = mask1 .* mask2 .* mask3;
    mask = mask*(gain-1)+1;
    pic = pic .* mask;
else     
    pic = pic*gain;
end

pic = uint16(pic);
writeSingleTif(pic, savepath);




end