
arate = 15.5;
preBoutSec = 3;  % Analyse 3s before start of the bout.
postBoutSec = 5; % Analyse 5s after the start of the bout.

animal = 'DL67';
date = '170601';
run = 6;

rundata = extractRunningData(animal, date, run, preBoutSec, postBoutSec);

df = runningCorrelationAnalysis(...
    rundata, {}, ...
    {}, ...
    {}...
);

boutID = unique({df.runningboutID});
timecourseLength = length(df(1).runningcorArray);

for i = 1:length(boutID)
    theboutID = boutID{i};
    subdf = df(strcmp({df.runningboutID}, theboutID));
    

    
    plot(subdf(1).runningcorArray);
    xticks(1:arate:timecourseLength);
    xticklabels(-preBoutSec:1:postBoutSec);
    xlabel('time course (sec)');
    ylabel('speed (m/s)');
    title('Running');

    %saveas(gcf,[bvfolder, 'bout ', num2str(i), ' diameter response.pdf']);
    exportgraphics(gcf,['D:\\test\run', num2str(run),'\bout ', num2str(i), ' diameter response.pdf'],'ContentType','vector')
    close;
end