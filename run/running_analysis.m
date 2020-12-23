function running_analysis(animal, date, run, varargin)
parser = inputParser;
addRequired(parser, 'animal', @ischar );
addRequired(parser, 'date', @ischar);
addRequired(parser, 'run', @isnumeric); 
parse(parser, animal, date, run, varargin{:});

root = sbxDir(animal, date, run);
root = root.runs{1}.path;
root = correct_folderpath([correct_folderpath(root), 'running']);
if ~exist(root, 'dir')
   mkdir(root);
end

path = sbxPath(animal, date, run, 'quad'); 
inf = sbxInfo(path, true);
if inf.scanmode == 1
    scanrate = 15;
elseif inf.scanmode == 2
    scanrate = 31;
end

result = struct();
result.array = getRunningArray(path);
result.scanrate = scanrate;
[tmp, result.secarray] = get_bout(result.array, scanrate);
result.bout = tmp.bout;

% plot the response pdf =============================================
% plot(result.secarray);
% hold on
% for i = 1:length(result.bout)
%     boutstart = max(result.bout{i}.startsec-1, 1);
%     boutend = min(result.bout{i}.endsec+1, floor(length(result.array)/scanrate));
%     direction = result.bout{i}.direction;
%     if direction == 1
%         plot([boutstart:boutend], result.secarray(boutstart:boutend),'color','green')
%     elseif direction == -1
%         plot([boutstart:boutend], result.secarray(boutstart:boutend),'color','red')
%     end
% end
% hold off
plot_running(result);
saveas(gcf,[root, 'response.pdf']);
close;

% save result ========================================================
save([root, 'result.mat'], 'result');

end