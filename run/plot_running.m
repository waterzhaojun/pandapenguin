function plot_running(result)

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
for i = 1:length(result.restbout)
    plot([result.restbout{i}.startsec,result.restbout{i}.endsec], [0.01,0.01], 'b');
end
hold off

set(gca,'TickDir','out');

end