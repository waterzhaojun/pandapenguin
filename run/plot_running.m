function plot_running(result)

hold on
% plot speed array. it has been bint to 1hz.
bar(result.secarray, 'black', 'EdgeColor','none');

% plot each bout.
for i = 1:length(result.bout)
    boutstart = max(result.bout{i}.startsec-1, 1);
    boutend = min(result.bout{i}.endsec+1, length(result.secarray));
%     direction = result.bout{i}.direction;
%     if direction == 1
    bar([boutstart:boutend], result.secarray(boutstart:boutend),'g','EdgeColor','none');
%     elseif direction == -1
%         bar([boutstart:boutend], result.secarray(boutstart:boutend),'r','EdgeColor','none');
%     end
end

% plot each rest period.
for i = 1:length(result.rest.result)
    startidx = ceil(result.rest.result(i).startidx / result.scanrate);
    endidx = floor(result.rest.result(i).endidx / result.scanrate);
    plot([startidx,endidx], [0.002,0.002], 'b');
end
hold off

set(gca,'TickDir','out');

end