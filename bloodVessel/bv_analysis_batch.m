function bv_analysis_batch(googleSheetID, varargin)

parser = inputParser;
addRequired(parser, 'googleSheetID', @ischar );
addParameter(parser, 'sheetID', '0');
addParameter(parser, 'bv_task_column', 6);
parse(parser,googleSheetID, varargin{:});

sheetID = parser.Results.sheetID;
bv_task_column = parser.Results.bv_task_column;

% ====================================================
explist = load_exp(googleSheetID);

for i = 2:length(explist)
    animal = explist(i).animal;
    date = explist(i).date;
    run = str2num(explist(i).run);
    pmt = str2num(explist(i).pmt);
    layers = get_existing_layers(animal, date, run);
    if length(layers) == 0
        mat2sheets(googleSheetID, sheetID, [i bv_task_column], {'No layer'});
    else
        for j = 1:length(layers)
            try
                [mx,folder] = diameter_prepare_mx(animal, date, run, pmt,'layer',layers{j});
                % As this function is for batch analysis, it will not involved in
                % identify the roi. So I just passed diameter_build_refmask step.
                % diameter_build_refmask(folder, mx, 'rebuildRef', false, 'rebuildRoi', false);
                set_scanrate(animal, date, run, 'bv');
                diameter_analysis(folder, mx);
                mat2sheets(googleSheetID, sheetID, [i bv_task_column], {'Done'});
            catch
                mat2sheets(googleSheetID, sheetID, [i bv_task_column], {'Failed'});
            end
        end
    end
    
end

end