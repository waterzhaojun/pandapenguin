% output movie and sbx
animalID = 'DL67';
dateID = '170411';
%run = [1:3]; % include all runs needed.
run = 1;
pmt = 0;
%layers = [0.7, 1];
%optsbx2tif(animalID, dateID, run, pmt, 0, layers);

% this part suppose to connect several sbx, but has problem===========
% savePath = sbxDir(animalID, dateID);
% savePath = [savePath.date_mouse, 'bv_diameter_change_', vector2str(run),'.mat'];
% if ~exist(savePath)
    
%     for i = 1:length(run)
%         if i == 1
%             sbx = optsbx2tif(animalID, dateID, run(i), pmt, 0, [0,1],0);
%         else
%             sbx = cat(3, sbx, optsbx2tif(animalID, dateID, run(i), pmt, 0, [0,1], 0));
%         end
%     end

%     save(savePath, 'sbx', '-v7.3'); 
% else
%     sbx = sbxread(savePath); % I didn't confirm this line works.
% end
% ===================================================================
sbx = optsbx2tif(animalID, dateID, run, pmt, 0, [0,1], 1);
savepath = sbxDir(animalID, dateID, run);
savepath = savepath.runs{1}.path;



% calculate blood vessel diameter. the code come from diameter.m
% =====================================================================
% step 1: draw roi
pic_ref = max(sbx(:,:,:)/65535, [], 3);
writetiff(pic_ref, [savepath, 'bvRefmap.tif']);
%figure, imshow(pic_ref);
%h = imline;
%pos = h.getposition();
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
angel = asin(ym/sqrt(xm*xm+ym*ym))*180/pi;
sbx_rotate = imrotate(sbx,angel);
BW_rotate = imrotate(BW, angel);
[p1r,p1c]=find(BW_rotate == 11);
[p2r,p2c]=find(BW_rotate == 22);
[p3r,p3c]=find(BW_rotate == 33);
sbxTmp = sbx_rotate(min(p1r, p2r):p3r, p1c:max(p2c, p3c),:);
imshow(sbxTmp(:,:,1)/65535);
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
for i = 1:size(sbx,3)
    output_topo(:,i) = mean(sbxTmp(:,:,i), 1);
    output_tl = [output_tl,findEdge(output_topo(:,i))];
end

%output to csv

bvSavePath = [savepath, 'bvValue.csv'];
if ~exist(bvSavePath)
    csvwrite(bvSavePath, output_tl);
else
    dlmwrite(bvSavePath, output_tl, 'delimiter', ',', '-append');
end

output_topo = uint8(3*output_topo/255);   % adjust the number if pic not strong enough)
output_tl = output_tl(output_tl >0);
save([files.date_mouse, 'bv_diameter.mat'], 'output_tl'); % change file name otherwise it will be replace in next run.
% ======================================================================
% ======================================================================
% eye
files = sbxDirJun(animalID, dateID);
for i = 1:length(run)
    if isempty(files.runs{run(i)}.eye) & ~isempty(files.runs{run(i)}.eyeSource)
        pupil = sbxPupil(animalID, dateID, run(i));
        save([files.runs{run(i)}.sbx(1:end-3), 'eye'], 'pupil');
        if i == 1
            pupil_total = pupil; 
        else
            pupil_total = cat(1, pupil_total, pupil);
        end
    end
    save([files.date_mouse, 'eye.mat'], 'pupil_total');
end

% ======================================================================
% ======================================================================
% run
for i = 1:length(run)
    if isempty(files.runs{run(i)}.speed) & ~isempty(files.runs{run(i)}.quad)
        speed = sbxSpeed(animalID, dateID, run(i));
        save([files.runs{1}.sbx(1:end-3), 'speed'], 'speed');
        if i == 1
            speed_total = speed; 
        else
            speed_total = cat(2, speed_total, speed);
        end
    end
    speed_total = mean(reshape(speed_total, floor(length(speed_total)/length(output_tl)), []), 1);
    save([files.date_mouse, 'speed.mat'], 'speed_total');
end


% plot=================================================================
% ========================================================================
figure
subplot(2,1,1);
plot(output_tl);
subplot(2,1,2);
plot(speed_total);
% ---------------------------------------------
imshow(output_topo);
plot(output_tl);

SEM = std(bb2)/sqrt(length(bb2));               % Standard Error
ts = tinv([0.025  0.975],length(bb2)-1);      % T-Score
CI = mean(bb2) + ts*SEM; 
bb3 = bb2(find(bb2<12.56 & bb2>7.188));


%------------------
figure
subplot(2,1,1);
imshow(area);
subplot(2,1,2);
imshow(area1);