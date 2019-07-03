workingFolder = 'C:\Users\Levylab\'

mov = VideoReader([workingFolder, 'Basler acA640-120um (21373914)_20180320_135054550.avi']);

outputVideo = VideoWriter([workingFolder, 'openv_v.avi']);
outputVideo.FrameRate = mov.FrameRate;
open(outputVideo);

for idx = 1:mov.NumberOfFrames
    
    img = 255 - read(mov, idx);

    writeVideo(outputVideo,img);
end

close(outputVideo);

imshow(img);

set(gcf,'Units','normalized')
k = waitforbuttonpress;
rect_pos = rbbox;
annotation('rectangle',rect_pos,'Color','red') 