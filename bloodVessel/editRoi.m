function editRoi(folder, mx, roiid,varargin)
% Sometimes the roi is not perfectly selected and may cause weird signal.
% This function is to help you change the roi without refill every
% information.

parser = inputParser;
addRequired(parser, 'folder' );
addRequired(parser, 'mx');
addRequired(parser, 'roiid');
addOptional(parser, 'updateDiameter', false);

parse(parser,folder, mx, roiid, varargin{:});
updateDiameter = parser.Results.updateDiameter;

folder = correct_folderpath(folder);
bvfilesys = bv_file_system();
result = load([folder, bvfilesys.resultpath]);
result = result.result;
rois = result.roi;
ref = read(Tiff([folder, result.refpath],'r'));

for i = 1:length(rois)
    tmpposition = rois{i}.position;
    if strcmp(rois{i}.id, roiid)
        flag = true;
        while flag
            BW = rois{i}.BW;
            newref = addroi(ref, BW);
            [newBW,newangle] = bwangle(newref);
            close;
            if strcmp(tmpposition, 'vertical')
               diameter = vertical_diameter_measure(mx, newBW);
            elseif strcmp(result.roi{i}.position, 'horizontal')
               diameter = calculate_diameter(mx, newBW, newangle);
            end
            plot(diameter);
            ylim([min(10,min(diameter)),max(45,max(diameter))]);
            title('Press Y for a good roi. Press N for a bad roi then choose again. Press Q to pass this one');
            waitforbuttonpress;
            g = get(gcf, 'CurrentCharacter');
            switch g
                case 'y'
                    result.roi{i}.BW = newBW;
                    result.roi{i}.angle = newangle;
                    save([folder, bvfilesys.resultpath], 'result');
                    flag = false;

                case 'n'
                    disp('Not satisfied. Choose again');

                case 'q'
                    flag = false;
            end
            close;
        end
    end
end

update_ref_with_mask(folder);

if updateDiameter
    diameter_analysis(folder, mx);
end


end