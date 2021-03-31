function res = extractBvData(animal, date, run, varargin)
parser = inputParser;
addRequired(parser, 'animal' );
addRequired(parser, 'date');
addRequired(parser, 'run');
addParameter(parser, 'excludeField', {'BW', 'angle'});
addParameter(parser, 'smooth', true);

parse(parser,animal, date, run, varargin{:});
smooth = parser.Results.smooth;

exp = sbxDir(animal, date, run);
res = [];
for i = 1:length(exp.runs{1}.bv.layer)
    tmp = load(exp.runs{1}.bv.layer{i}.resultpath);
    tmp = tmp.result;
    
    % organize the struct
    for j = 1:length(tmp.roi)
        tmp.roi{j}.scanrate = tmp.scanrate;
        [~, tmp.roi{j}.layer] = fileparts(exp.runs{1}.bv.layer{i}.folder(1:end-1));
        for k = 1:length(parser.Results.excludeField)
            if isfield(tmp.roi{j}, parser.Results.excludeField{k})
                tmp.roi{j} = rmfield(tmp.roi{j}, parser.Results.excludeField{k});
            end
        end
    end
    
    % copy all roi to res
    for j = 1:length( tmp.roi )
        if length(res) == 0
            res = [tmp.roi{j}];
        else
            res = [res;tmp.roi{j}];
        end
    end
    
    
end

% add some extra column. 
for i = 1:length(res)
    res(i).diameterRaw = res(i).diameter;
    res(i).diameter = gaussfilt(1:length(res(i).diameter), res(i).diameter, 3);
    res(i).drr = (res(i).diameter - res(i).diameter_baseline) / res(i).diameter_baseline;
end

% treat the diameter by filter. 
if smooth
    for i = 1:length(res)
        res(i).diameterRaw = res(i).diameter;
        res(i).diameter = gaussfilt(1:length(res(i).diameter), res(i).diameter, 3);
    end
end


end