function res = get_animal_info(varargin)
parser = inputParser;
addOptional(parser, 'animal', '');
addParameter(parser, 'googleSheetId', '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ');
addParameter(parser, 'googleSheetTab', '102916024');
parse(parser, varargin{:});

animal = parser.Results.animal;
googleSheetId = parser.Results.googleSheetId;
googleSheetTab = parser.Results.googleSheetTab;

res = GetGoogleSpreadsheet_edited(googleSheetId, googleSheetTab);

res = cell2struct(res, {res{1, :}}, 2);

if length(animal) > 0 
    res = res(strcmp({res.animal}, animal));
end

end