function plot_running(result)

% deprecated. use plot_running_realfs.

config = run_config();
hold on
% plot speed array. it has been bint to 1hz.
bar(result.secarray_treated, 'black', 'EdgeColor','none');

% plot each bout.
for i = 1:length(result.bout)
    boutstart = max(result.bout{i}.startsec, 1);
    boutend = min(result.bout{i}.endsec, length(result.secarray));
%     direction = result.bout{i}.direction;
%     if direction == 1
    bar([boutstart:boutend], result.secarray_treated(boutstart:boutend),'g','EdgeColor','none');
%     elseif direction == -1
%         bar([boutstart:boutend], result.secarray(boutstart:boutend),'r','EdgeColor','none');
%     end
end

% plot each rest period.
if strcmp(result.boutMethod, 'drewlab')
    for i = 1:length(result.restbout)
        plot([result.restbout{i}.startsec,result.restbout{i}.endsec], [config.acceleration_threshold,config.acceleration_threshold], 'b');
    end
end
hold off

set(gca,'TickDir','out');

end