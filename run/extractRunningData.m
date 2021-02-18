function df = extractRunningData(animal, date, run, varargin)
parser = inputParser;
addRequired(parser, 'animal' );
addRequired(parser, 'date');
addRequired(parser, 'run');
addOptional(parser, 'preBoutSec', 5);
addOptional(parser, 'postBoutSec', 10);
addParameter(parser, 'excludeField', {});
addParameter(parser, 'boutFilter', {});
parse(parser,animal, date, run, varargin{:});

preBoutSec = parser.Results.preBoutSec;
postBoutSec = parser.Results.postBoutSec;
boutFilter = parser.Results.boutFilter;

exp = sbxDir(animal, date, run);
res = load(exp.runs{1}.running.resultpath);
res = res.result;
scanrate = res.scanrate;

config = run_config();

restidx = res.restidx;
restmean = mean(res.array_treated(restidx));
reststd = std(res.array_treated(restidx));

% organize bout df
for i = 1:length(res.bout)
    tmp = res.bout{i};
    tmp.scanrate = res.scanrate;
    if tmp.startidx-ceil(preBoutSec*scanrate) < 1
        continue
    else
        tmp.baselineIdx = [tmp.startidx-ceil(preBoutSec*scanrate), tmp.startidx - 1];
    end
    
    if tmp.startidx+ceil(postBoutSec*scanrate)-1 > length(res.array)
        continue
    else
        tmp.responseIdx = [tmp.startidx, tmp.startidx+ceil(postBoutSec*scanrate)-1];
    end
    
    tmp.corArray = res.array_treated(tmp.baselineIdx(1) : tmp.responseIdx(2));
    tmp.baselineArray = res.array_treated(tmp.baselineIdx(1) : tmp.baselineIdx(2));
    tmp.responseArray = res.array_treated(tmp.responseIdx(1) : tmp.responseIdx(2));
    
    tmp.boutID = [animal, '_', date, '_run', num2str(run), '_bout', num2str(i)];
    for k = 1:length(parser.Results.excludeField)
        if isfield(tmp, parser.Results.excludeField{k})
            tmp = rmfield(tmp, parser.Results.excludeField{k});
        end
    end
    
    if i == 1
        df = [tmp];
    else
        df = [df;tmp];
    end
end

for i = 1:length(boutFilter)
   if strcmp(boutFilter{i}, 'cleanPreBoutPeriodByMedian')
       keepbout = [];
       for b = 1:length(df)
           if median(df(b).baselineArray) < restmean + reststd
               keepbout = [keepbout, b];
           end
       end
       df = df(keepbout);
   elseif strcmp(boutFilter{i}, 'cleanPreBoutPeriodByQuietPercentage')
       keepbout = [];
       for b = 1:length(df)
           sum(df(b).baselineArray < restmean + reststd) / length(df(b).baselineArray)
           if sum(df(b).baselineArray < config.speed_threshold) / length(df(b).baselineArray) > 0.2%restmean + reststd
               keepbout = [keepbout, b];
           end
       end
       df = df(keepbout);
   end
end
       
        

end