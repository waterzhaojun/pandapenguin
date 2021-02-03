function runningCorrelationPlot(runningStructDf, corrStructDfCell, analyseCorrArrayField, corrid)

% Based on running struct data, get the correlation analysis result. a
% sample is:
% runningCorrelationPlot(rundata, {bvdata, regdata}, {{'diameter'},{'trans_x', 'trans_y'}}, {'layer','layer'})
%
%

plotc = length(runningStructDf);
plotr = sum(cellfun(@length,analyseCorrArrayField) .* cellfun(@length,corrStructDfCell)) + 1;

idx = 1;
for i = 1:length(corrStructDfCell)
    corrdf = corrStructDfCell{i};
    corrAnalyseField = analyseCorrArrayField{i};
    for j = 1:length(corrAnalyseField)
        analyseField = corrAnalyseField{j};
        for k = 1:length(corrdf)
            array = corrdf(k).(analyseField);
            arrayYLabel = corrdf(k).(corrid{i});
            for m = 1:length(runningStructDf)
                boutbaselineidx = runningStructDf(m).baselineIdx;
                boutresidx = runningStructDf(m).responseIdx;
                boutscanrate = runningStructDf(m).scanrate;
                corrScanrate = corrdf(k).scanrate;

                corrArrayBaselineStartIdx = translateIdx(boutbaselineidx(1), boutscanrate, corrScanrate);
                corrArrayBaselineEndIdx = translateIdx(boutbaselineidx(2), boutscanrate, corrScanrate);

                baseline = mean(array(corrArrayBaselineStartIdx:corrArrayBaselineEndIdx));
                corrArrayRespStartIdx = translateIdx(boutresidx(1), boutscanrate, corrScanrate);
                corrArrayRespEndIdx = translateIdx(boutresidx(2), boutscanrate, corrScanrate);

                rems = ceil(corrArrayRespEndIdx - corrArrayBaselineStartIdx + 1 - ((boutresidx(2) - boutbaselineidx(1) + 1) * corrScanrate / boutscanrate));
                %disp(rems)
                corrArray = array(corrArrayBaselineStartIdx:corrArrayRespEndIdx);% - rems);
                subplot(plotr, plotc, idx);
                plot(corrArray);
                hold on
                yline(baseline);
                hold off
                ylabel(arrayYLabel);
                idx = idx + 1;
            end
        end
    end
end

for i = 1:length(runningStructDf)
    subplot(plotr, plotc, idx);
    plot(runningStructDf(i).corArray');
    idx = idx +1;
end

end