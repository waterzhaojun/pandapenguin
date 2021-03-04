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
ref = imread([folder, result.refpath]);
% Until to this step, the result should contain path information and roi
% mask and angles. We start to build extra value.

% add diameter length pixel ratio.
[animal, date, run] = pathTranslate(folder);
[result.x_ratio, result.y_ratio] = diameter_pixel_ratio(animal, date, run);


% figure('Position', [10 10 2500, 600 * 2 * length(result.roi)]);
% tiledlayout(2*length(result.roi), 1);
roi_per_page = 3;

for i = 1:length(result.roi)
    tmpposition = result.roi{i}.position;
    tmpbw = result.roi{i}.BW;
    if strcmp(tmpposition, 'vertical')
       [diameter, response_fig, response_mov] = vertical_diameter_measure(mx, tmpbw);
       result.roi{i}.diameter = diameter * (result.x_ratio + result.y_ratio)/2;
       result.roi{i}.response_mov_path= ['roi_', num2str(i),'_response_mov.tif'];
       % To avoid produce super big tif, I downsample output mov to 1hz.
       response_mov = downsamplef(response_mov, round(result.scanrate));

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

    if rem(i,roi_per_page) == 1
        figure('Position', [10 10 1500, 600 * 2 * roi_per_page *1.5]);
        tiledlayout(2*roi_per_page, 5);
    end

    nexttile([1,3])
    plot(result.roi{i}.diameter);
    xlim([1,length(result.roi{i}.diameter)]);
    if isfield(result.roi{i}, 'id')
        title(result.roi{i}.id);
    end

    nexttile([2,2])
    ref_with_this_mask = addroi(ref, result.roi{1}.BW);
    imshow(imresize(ref_with_this_mask, [NaN, 600]));

    nexttile([1,3])
    imshow(imresize(uint16(response_fig),[100,1500])); % Right now just use manual way to define ratio. Need to change to a better way.

    if rem(i, roi_per_page) == 0 || i == length(result.roi)
        tmpresponsefile = strsplit(result.response_fig_path, '.');
        tmpresponsefile = [tmpresponsefile{1}, '_', num2str(ceil(i/roi_per_page)), '.', tmpresponsefile{2}];
        saveas(gcf,[folder,tmpresponsefile]);
        close;
    end
    
end


save([folder,bvfilesys.resultpath], 'result');

end