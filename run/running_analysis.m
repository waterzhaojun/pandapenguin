function running_analysis(animal, date, run, varargin)
parser = inputParser;
addRequired(parser, 'animal', @ischar );
addRequired(parser, 'date', @ischar);
addRequired(parser, 'run', @ischar); 
parse(parser, animal, date, run, varargin{:});

path = sbxPath(animal, date, run, 'quad'); 
inf = sbxInfo(path, true);
if inf.scanmode == 1
    scanrate = 15;
elseif inf.scanmode == 2
    scanrate = 31;
end

result = struct();
result.array = getRunningArray(path);
[tmp, result.secarray] = get_bout(result.array, scanrate);
result.bout = tmp.bout;
plot(result.secarray);
hold on
for i = 1:length(result.bout)
    boutstart = result.bout{i}.startsec;
    boutend = result.bout{i}.endsec;
    direction = result.bout{i}.direction;
    if direction == 1
        plot([boutstart:boutend], result.secarray(boutstart:boutend),'color','green')
    elseif direction == -1
        plot([boutstart:boutend], result.secarray(boutstart:boutend),'color','red')
    end
end
hold off

end