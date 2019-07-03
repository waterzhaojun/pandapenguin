function analogInput(arduino, duration, savePath, hz)

    % duration is counted by second.
    % arduino=serial('COM3','BaudRate',9600);
    fopen(arduino);
    recordDuration = duration * hz;
    x=linspace(1,recordDuration, recordDuration);
    h = animatedline;
    for(i = 1:100)
        m(i) = fread(arduino, 1, 'int32');
    end

    axis([0 length(x) 0 max(m)*2])

    for i=1:length(x)

        y=0;
        if ~isempty(arduino)
            y = fread(arduino, 1, 'int32');

        end

        fileID = fopen([savePath, 'analogSignal.txt'],'a');
        fprintf(fileID,'%d \n', y);
        fclose(fileID);

        addpoints(h,x(i), y);
        drawnow limitrate
        pause(1/hz);
    end
    
    fclose(arduino);
end