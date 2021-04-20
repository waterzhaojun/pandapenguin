function plot_running(result, varargin)

% This function is to plot a running figure based on result. The default is
% to just plot one timecouse either real frequency treated array, or 1hz
% treated array by setting 'datatype'. If you want to plot a more detailed
% figure, set 'detail' to true. 

parser = inputParser;
addRequired(parser, 'result'); % the running result struct
addParameter(parser, 'datatype', 'treated', @ischar);
addParameter(parser, 'detail', false, @islogical);
addParameter(parser, 'distanceUnit', 'cm', @ischar); % The original distance unit is m. If show cm, the value need to times 100;
parse(parser, result, varargin{:});

detail = parser.Results.detail;
datatype = parser.Results.datatype;
distanceUnit = parser.Results.distanceUnit;

if strcmp(distanceUnit, 'cm')
    unitAmp = 100;
elseif strcmp(distanceUnit, 'm')
    unitAmp = 1;
end
    
config = run_config();

% Set the data we want to plot
if strcmp(datatype, 'treated_sec')
    wholearray = result.secarray_treated;
    boutstartlabel = 'startsec';
    boutendlabel = 'endsec';
elseif strcmp(datatype, 'treated')
    wholearray = result.array_treated;
    boutstartlabel = 'startidx';
    boutendlabel = 'endidx';
elseif strcmp(datatype, 'all')
end
    
if detail
    fig = tiledlayout(3,1);
    ax1 = nexttile([2,1]);
else
    fig = figure();
end

hold on
% plot speed array. it has been bint to 1hz.
bar(wholearray * unitAmp, 'black', 'EdgeColor','none', 'FaceAlpha', 0.5);

% plot each bout.
for i = 1:length(result.bout)
    boutstart = max(result.bout{i}.(boutstartlabel), 1);
    boutend = min(result.bout{i}.(boutendlabel), length(wholearray));
%     direction = result.bout{i}.direction;
%     if direction == 1
    bar([boutstart:boutend], wholearray(boutstart:boutend) * unitAmp,'r','EdgeColor','none', 'FaceAlpha', 0.5);
%     elseif direction == -1
%         bar([boutstart:boutend], result.secarray(boutstart:boutend),'r','EdgeColor','none');
%     end
end

% plot each rest period.
if strcmp(result.boutMethod, 'drewlab')
    for i = 1:length(result.restbout)
        plot([result.restbout{i}.(boutstartlabel),result.restbout{i}.(boutendlabel)], [config.acceleration_threshold*unitAmp,config.acceleration_threshold*unitAmp], 'b');
    end
end
hold off

if strcmp(result.boutMethod, 'drewlab')
    ylabel(['Acceleration (', distanceUnit, '/s2)']);
elseif strcmp(result.boutMethod, 'markov')
    ylabel(['Speed (', distanceUnit, '/s)']);
end



set(gca,'TickDir','out');

if detail
    ax2 = nexttile;
    bar(1:length(result.array), result.array);
    linkaxes([ax1 ax2],'x');
end

end