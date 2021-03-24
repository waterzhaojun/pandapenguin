function [stripmx, startidx, endidx] = choose_linescan_strip(mx)

B = imgaussfilt3(mx);
ref = min(B, [], 3);
[r,c] = size(ref);
imshow(imadjust(ref));
%h = images.roi.Line(gca,'Position',[round(0.2*c) round(0.5*r); round(0.8*c) round(0.5*r)]);
h = drawline('Position',[round(0.2*c) round(0.5*r); round(0.8*c) round(0.5*r)]);
title('Adjust bar. Press q to quit');
flag = 1;
while flag
    waitforbuttonpress;
    p = get(gcf, 'CurrentCharacter');
    switch p
        case 'q'
           position = h.Position;
           flag = 0;
    end
end
close;
startidx = position(1,1);
endidx = position(2,1);
stripmx = mx(:,startidx:endidx,:);

    
end