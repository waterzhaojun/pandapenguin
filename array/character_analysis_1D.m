function res = character_analysis_1D(array, startidx, endidx, scanrate, baseline_seclength, varargin)
parser = inputParser;
addRequired(parser, 'array', @isnumeric );
addRequired(parser, 'startidx', @isnumeric);
addRequired(parser, 'endidx', @isnumeric); 
addRequired(parser, 'scanrate', @isnumeric);
addRequired(parser, 'baseline_seclength', @isnumeric);
addParameter(parser, 'dff', true, @islogical);
addParameter(parser, 'baseline_value', 'N');
addParameter(parser, 'analyze_response_secrange', 'N'); % This value should be a two element array, unit is sec after the start of the response. like [0,2] means from 0 sec to 2 sec after response start.
parse(parser, array, startidx, endidx, scanrate, baseline_seclength, varargin{:});

if strcmp(parser.Results.analyze_response_secrange, 'N')
    analyzerange = [0, endidx-startidx];
else
    analyzerange = [parser.Results.analyze_response_secrange(1) * scanrate,...
        parser.Results.analyze_response_secrange(2) * scanrate];
end

res = struct();
baselinelength = baseline_seclength * scanrate;
baseline_idx_start = startidx - baselinelength;
baseline_idx_end = startidx - 1;
% if baseline_idx_end < 1
%     error('No space for baseline, please check your index');
% end
if analyzerange(1) > endidx
    error('The analyze range is out of response range');
end
% I think analyze range should include possiblly out of real response
% timepoint as this might be a possible response too.
% analyzerange(2) = min(endidx - startidx+1, analyzerange(2)); 

if baseline_idx_end < 1
    res.baseline = array(startidx);
    baseline_array = repmat(res.baseline, 1, baselinelength);
    res.baseline_negative = 1;
else
    if baseline_idx_start > 1
        baseline_array = array(baseline_idx_start : baseline_idx_end);
        res.baseline = mean(baseline_array);
    else
        extrapoint = baselinelength - startidx + 1;
        baseline_idx_start = 1;
        if strcmp(parser.Results.baseline_value, 'N')
            res.baseline = mean(array(baseline_idx_start:baseline_idx_end));
        else
            res.baseline = parser.Results.baseline_value;
        end

        baseline_array = [repmat(res.baseline, 1,extrapoint), ...
            array(baseline_idx_start:baseline_idx_end)];
    end
end

response_array = array(startidx:endidx);
analyze_response_array = array(startidx + analyzerange(1):startidx + analyzerange(2)-1);

if parser.Results.dff
    baseline_array = (baseline_array - res.baseline) / res.baseline;
    response_array = (response_array - res.baseline) / res.baseline;
    analyze_response_array = (analyze_response_array - res.baseline) / res.baseline;
end

% The difference of response_array and analyze_response_array is
% response_array cover the natrual response period like a bout's period.
% analyze_response_array is the period I want to analyze. This period can
% be short or longer than the response_array.
res.baseline_array = baseline_array;
res.response_array = response_array;
res.analyze_response_array = analyze_response_array;

% When we analyze the characters, we should use analyze_response_array
% because this is the period we are interested.
[res.response_max, res.response_max_idx] = max(analyze_response_array);
%[res.response_max, res.response_max_idx] = max(response_array(analyzerange(1)+1:analyzerange(2)));
res.response_mean = mean(analyze_response_array);
res.response_acceleration = res.response_max * scanrate / res.response_max_idx;




end