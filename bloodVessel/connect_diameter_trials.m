function connect_diameter_trials(source, outputfolder, varargin)
% This function is to connect one roi cross multiple trials. 
% The source should be a cell. In each element the first element should be the path, and the second element should be roi id.

parser = inputParser;
addRequired(parser, 'source', @iscell ); 
addRequired(parser, 'outputfolder', @iscell ); 
parse(parser,source,outputfolder,varargin{:});

outputfolder = correct_folderpath(outputfolder);
if ~exist(outputfolder, 'dir')
   mkdir(outputfolder)
end

result = struct();
result.movpath = 'mov.tif';
result.refpath = 'ref.tif';
result.ref_with_mask_path = 'ref_with_mask.tif';
result.resultpath = 'result.mat';
result.response_fig_path = 'response.pdf';
% The source path should only start from date_animal. I don't think we will
% connect data across animal.
result.source = {};


for i = 1:size(source, 1)
   root = correct_folderpath(source{i,1});
   result = load([root, 'result.mat']);
   result = result.result;
   if i == 1
       moviemx = loadTiffStack_slow([root, result.movpath]);
       tmp = imread([root, result.refpath]);
       refmx = reshape(tmp, size(tmp,1), size(tmp,2),1);
       bwmx = result.roi{source{i,2}}.BW;
   else
       moviemx = cat(4,moviemx, loadTiffStack_slow([root, result.movpath]));
       tmp = imread([root, result.refpath]);
       refmx = cat(3,refmx, reshape(tmp, size(tmp,1), size(tmp,2),1));
       bwmx = bwmx + result.roi{source{i,2}}.BW;
   end
   tmp = strsplit(source{i,1},'\');
   tmp = [tmp{end-3},'\',tmp{end-2},'\',tmp{end-1},'\',tmp{end},'\'];
   tmpid = source{i,2};
   result.source = cat(1,{tmp,tmpid});
end
   
% output movie.
mx2tif(moviemx, [outputfolder,result.movpath]);

% output ref.
ref = uint16(mean(refmx, 3));
imwrite(ref, [outputfolder,result.refpath]);

% output ref with mask.
bwmx = (bwmx > 0) *1;
ref_withmask = uint16(addroi(ref, bwmx));
imwrite(ref_withmask, [outputfolder,result.ref_with_mask_path]);
   




end