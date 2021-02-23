function andy_registration_batch(googleSheetID, varargin)


parser = inputParser;
addRequired(parser, 'googleSheetID', @ischar );
addOptional(parser, 'list', 'all');
addParameter(parser, 'sheetID', '0');
addParameter(parser, 'reg_task_column', 7);
parse(parser,googleSheetID, varargin{:});

list = parser.Results.list;
sheetID = parser.Results.sheetID;
reg_task_column = parser.Results.reg_task_column;

javaaddpath('C:\Users\Levylab\jun\pandapenguin\packages\AffineRegistration\miji jars\TurboRegHL_.jar')
javaaddpath('C:\Users\Levylab\jun\pandapenguin\packages\AffineRegistration\miji jars\mij.jar')
javaaddpath('C:\Users\Levylab\jun\pandapenguin\packages\AffineRegistration\miji jars\ij-1.52a.jar')

explist = load_exp(googleSheetID);

if strcmp(list, 'all')
    list = 2:length(explist);
end

for i = list%[45]%2:length(explist)
    try
        server = 'C:\2pdata';
        expt.mouse = explist(i).animal;%'CGRP0716'; 
        expt.date = explist(i).date;%'210129';
        expt.runs = [str2num(explist(i).run)];%[5];
        expt.dir = sprintf('%s\\%s\\%s_%s\\', server, expt.mouse, expt.date, expt.mouse); %strcat( server, fSep, expt.mouse
        expt.name = sprintf('%s_%s', expt.mouse, expt.date);
        expt.Nruns = numel(expt.runs); 

        % Get run-level metadata, locomotion and time data 
        %for r = expt.runs 
        r = expt.runs; 
        runInfo(r) = MakeInfoStruct( expt, r ); %expt.mouse, expt.date
        quadPath{r} = sprintf('%s%s_quadrature.mat', runInfo(r).dir, runInfo(r).fileName);
        loco(r) = GetLocoData( quadPath{r}, runInfo(r) ); % DuraDataPath(expt.mouse, expt.date, r, 'quad')
        %end
        %[Tscan, runInfo] = GetTime(runInfo);
        expt.Nplane = runInfo(1).Nplane;
        expt.totScan = runInfo(1).totScan;

        % Affine registration 
        affParams.refChan = 1;  %1; %1 = red, 2 = green
        affParams.refRun = NaN;
        affParams.refScan = [];%k,m,sdf
        affParams.chunkSize = 1;
        affParams.histmatch = false;
        affParams.binXY = 2;
        affParams.binT = 1;
        affParams.prereg = false;
        affParams.highpass = 0;
        affParams.lowpass = 0;
        affParams.medFilter = [0,0,0];
        affParams.minInt = 1600;
        %rawProj = loadtiff('D:\2photon\WT0118\201123_WT0118\201123_WT0118_run1\WT0118_201123_run_1_rawProj.tif');
        affParams.edges = [80,80,20,20]; %GetEdges(rawProj, 'minInt',1600, 'show',true);
        affParams.refScan = [];
        for r = expt.runs 
            RegisterCat3D(runInfo(r), affParams, 'overwrite',false, 'writeZ',true, 'refChan',1);  % 
        end
        mat2sheets(googleSheetID, sheetID, [i reg_task_column], {'Done'});
    catch
        mat2sheets(googleSheetID, sheetID, [i reg_task_column], {'Failed'});
    end
end



% For single plane test: CGRP0716, 210129, 5
% For z stack test: WT0120, 201223, 1





end