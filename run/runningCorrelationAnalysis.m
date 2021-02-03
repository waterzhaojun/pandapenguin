function df = runningCorrelationAnalysis(runningStructDf, corrStructDfCell, corrHeads, analyseCorrArrayField)

% Based on running struct data, get the correlation analysis result. a
% sample is:
% df = runningCorrelationAnalysis(rundata, {bvdata, regdata}, {'bv', 'reg'}, {{'diameter'}, {'trans_x', 'trans_y'}})
%
%
for i = 1:length(analyseCorrArrayField)
    analyseCorrArrayField{i} = append(corrHeads{i}, analyseCorrArrayField{i});
end

df = correlationData([{runningStructDf}, corrStructDfCell], [{'running'}, corrHeads]);
idx = 1
for i = 1:length(df)
    boutbaselineidx = df(i).runningbaselineIdx;
    boutresidx = df(i).runningresponseIdx;
    
    for j = 1:length(analyseCorrArrayField)
        for k = 1:length(analyseCorrArrayField{j})
            arrayFieldName = analyseCorrArrayField{j};
            arrayFieldName = arrayFieldName{k};
            
            array = df(i).(arrayFieldName);
            corrArrayScanrate = df(i).([corrHeads{j}, 'scanrate']);
            corrArrayBaselineStartIdx = translateIdx(boutbaselineidx(1), df(i).runningscanrate, corrArrayScanrate);
            corrArrayBaselineEndIdx = translateIdx(boutbaselineidx(2), df(i).runningscanrate, corrArrayScanrate);
            df(i).([corrHeads{j}, '_bout_baseline']) = mean(array(corrArrayBaselineStartIdx:corrArrayBaselineEndIdx));
            df(i).([corrHeads{j}, '_bout_baseline_array']) = array(corrArrayBaselineStartIdx:corrArrayBaselineEndIdx);
            corrArrayRespStartIdx = translateIdx(boutresidx(1), df(i).runningscanrate, corrArrayScanrate);
            corrArrayRespEndIdx = translateIdx(boutresidx(2), df(i).runningscanrate, corrArrayScanrate);
            df(i).([corrHeads{j}, '_bout_response_array']) = array(corrArrayRespStartIdx:corrArrayRespEndIdx);
            rems = corrArrayRespEndIdx - corrArrayBaselineStartIdx + 1 - ((boutresidx(2) - boutbaselineidx(1) + 1) * corrArrayScanrate / df(i).runningscanrate);
            df(i).([corrHeads{j}, '_bout_timecourse']) = array(corrArrayBaselineStartIdx:corrArrayRespEndIdx - rems);

            idx = idx + 1;
        end
    end
end


end