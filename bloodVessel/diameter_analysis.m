function diameter_analysis(folder, mx, varargin)

parser = inputParser;
addRequired(parser, 'folder', @ischar );
addRequired(parser, 'mx', @ischar );
parse(parser,folder,mx,varargin{:});

folder = correct_folderpath(folder);
bvfilesys = bv_file_system();
result = load([folder, bvfilesys.resultpath]);
result = result.result;

subplotnum = 2*length(result.roi);
figure();
for i = 1:length(result.roi)
   tmpposition = result.roi{i}.position;
   tmpbw = result.roi{i}.BW;
   if strcmp(tmpposition, 'vertical')
       [result.roi{i}.diameter, response_fig, response_mov] = vertical_diameter_measure(mx, tmpbw);
       result.roi{i}.response_mov_path= ['roi_', num2str(i),'_response_mov.tif'];
       if max(response_mov, [],'all') > 256
           response_mov = response_mov/256;
       end
       mx2tif(uint8(response_mov), [folder,result.roi{i}.response_mov_path]);
   elseif strcmp(result.roi{i}.position, 'horizontal')
       tmpangle = result.roi{i}.angle;
       [result.roi{i}.diameter, response_fig] = calculate_diameter(mx, tmpbw, tmpangle);
   end
   
    subplot(subplotnum, 1, 2*i-1);
    plot(result.roi{i}.diameter);
    xlim([1,length(result.roi{i}.diameter)]);

    subplot(subplotnum, 1, 2*i);
    imshow(imresize(uint16(response_fig),[100,1500])); % Right now just use manual way to define ratio. Need to change to a better way.

end
saveas(gcf,[path,result.response_fig_path]);
close;

save([folder,bvfilesys.resultpath], 'result');

end