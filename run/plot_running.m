function plot_running(result)

plot(result.secarray);
hold on
for i = 1:length(result.bout)
    boutstart = max(result.bout{i}.startsec-1, 1);
    boutend = min(result.bout{i}.endsec+1, floor(length(result.array)/result.scanrate));
    direction = result.bout{i}.direction;
    if direction == 1
        plot([boutstart:boutend], result.secarray(boutstart:boutend),'color','green')
    elseif direction == -1
        plot([boutstart:boutend], result.secarray(boutstart:boutend),'color','red')
    end
end
hold off

end