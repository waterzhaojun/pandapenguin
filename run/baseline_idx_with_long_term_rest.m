function restperiod = baseline_idx_with_long_term_rest(result, varargin)

% This function is to identify a long term rest period and grab a piece
% from the last seconds. This method is used in Drew lab's paper.
parser = inputParser;
addRequired(parser, 'result');
addParameter(parser, 'rest_period_length_threshold', 30); % The threshold of rest period length. Unit is sec.
addParameter(parser, 'baseline_piece_length', 10); % The length that used for baseline. Unit is sec.
addParameter(parser, 'gap_to_end', 1); % The baseline piece to the end of this rest period. Unit is sec.
parse(parser,result, varargin{:});

rest_period_length_threshold = parser.Results.rest_period_length_threshold * result.scanrate;
baseline_piece_length = round(parser.Results.baseline_piece_length * result.scanrate);
gap_to_end = round(parser.Results.gap_to_end * result.scanrate);

restperiod = [];
for i = 1:length(result.restbout)
    %disp((result.restbout{i}.endidx - result.restbout{i}.startidx)/result.scanrate);
    if result.restbout{i}.endidx - result.restbout{i}.startidx + 1 > rest_period_length_threshold
        restperiod = [restperiod, result.restbout{i}.endidx - baseline_piece_length - gap_to_end + 1 : result.restbout{i}.endidx - gap_to_end];
    end
end
    





end