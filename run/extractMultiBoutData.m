function df = extractMultiBoutData(exp, varargin)

% This function is by give an exp struct table, which contains animal,
% date, run, we extract bout data and combine it to a big dataframe struct.

% So far I prefer the exp is from google sheet that has animal, date, run,
% treatment. May need edit to from more source.


parser = inputParser;
addRequired(parser, 'exp');
addOptional(parser, 'extraCols', {});
parse(parser,exp, varargin{:});

extraCols = parser.Results.extraCols;

for i = 1:length(exp)
    animal = exp(i).animal;
    date = exp(i).date;
    run = exp(i).run;
    path = sbxDir(animal, date, run);
    res = load(path.runs{1}.running.resultpath);
    res = res.result;
    scanrate = res.scanrate;

    

    % add some information to bout df
    for j = 1:length(res.bout)
        tmp = res.bout{j};
        tmp.boutID = [animal, '_', date, '_run', num2str(run), '_bout', num2str(j)];
        tmp.scanrate = scanrate;
        
        for k = 1:length(extraCols)
            tmp.(extraCols{k}) = exp(i).(extraCols{k});
        end
        
        if exist('df','var')
            df = [df;tmp];
        else
            df = [tmp];
        end
    
    end

end

end