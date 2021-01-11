function diameter_analysis(folder, mx, varargin)
% This function should run after prepared ROI. It is to do diameter
% calculate based on mx and that layer's folder.

parser = inputParser;
addRequired(parser, 'folder', @ischar );
addRequired(parser, 'mx' );
addParameter(parser, 'rebuild', false); % Not using yet
parse(parser,folder,mx,varargin{:});

folder = correct_folderpath(folder);
bvfilesys = bv_file_system();
result = load([folder, bvfilesys.resultpath]);
result = result.result;
% Until to this step, the result should contain path information and roi
% mask and angles. We start to build extra value.

% add diameter length pixel ratio.
[animal, date, run] = pathTranslate(folder);
[result.x_ratio, result.y_ratio] = diameter_pixel_ratio(animal, date, run);

subplotnum = 2*length(result.roi);
figure();
for i = 1:length(result.roi)
   tmpposition = result.roi{i}.position;
   tmpbw = result.roi{i}.BW;
   if strcmp(tmpposition, 'vertical')
       [diameter, response_fig, response_mov] = vertical_diameter_measure(mx, tmpbw);
       result.roi{i}.diameter = diameter * (result.x_ratio + result.y_ratio)/2;
       result.roi{i}.response_mov_path= ['roi_', num2str(i),'_response_mov.tif'];
       % To avoid produce super big tif, I downsample output mov to 1hz.
       response_mov = downsamplef(response_mov, result.scanrate);
      
       if max(response_mov, [],'all') > 256
          response_mov = response_mov/256;
       end
       mx2tif(uint8(response_mov), [folder,result.roi{i}.response_mov_path]);
   elseif strcmp(result.roi{i}.position, 'horizontal')
       tmpangle = result.roi{i}.angle;
       [diameter, response_fig] = calculate_diameter(mx, tmpbw, tmpangle);
       result.roi{i}.diameter = diameter * ...
           sqrt(cos(abs(tmpangle)*pi/180)^2*result.x_ratio^2 + sin(abs(tmpangle)*pi/180)^2*result.y_ratio^2);
           
   end
   
    subplot(subplotnum, 1, 2*i-1);
    plot(result.roi{i}.diameter);
    xlim([1,length(result.roi{i}.diameter)]);

    subplot(subplotnum, 1, 2*i);
    imshow(imresize(uint16(response_fig),[100,1500])); % Right now just use manual way to define ratio. Need to change to a better way.

end

saveas(gcf,[folder,result.response_fig_path]);
close;

save([folder,bvfilesys.resultpath], 'result');

end