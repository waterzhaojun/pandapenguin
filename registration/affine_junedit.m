function edges = affine_junedit(sbxPath, refPath, varargin)
% Use TurboReg to affine register each plane of a volume scan movie
IP = inputParser;
addRequired( IP, 'sbxPath', @ischar )
addRequired( IP, 'refPath', @ischar )
addParameter( IP, 'refChan', 0, @isnumeric ) % for scanbox, 1 = green, 2 = red. -1 = both
addParameter( IP, 'refScan', [], @isnumeric )
addParameter( IP, 'scale', 2, @isnumeric ) %
addParameter( IP, 'minInt', 2000, @isnumeric ) %
addParameter( IP, 'overwrite', false, @islogical )
addParameter( IP, 'edges', [], @isnumeric )
parse( IP, sbxPath, refPath, varargin{:} ); 
refChan = IP.Results.refChan;  %1; %1 = red, 2 = green
refScan = IP.Results.refScan;
scaleFactor = IP.Results.scale;
overwrite = IP.Results.overwrite;
minInt = IP.Results.minInt;
edges = IP.Results.edges;

[fDir, fName, ~] = fileparts(sbxPath);  fSep = '\';
tformPath = strcat(fDir,fSep,fName,'_affine_tforms.mat');
edgeMax = [100, 100, 120, 120]; % [left, right, top, bottom]  
% load metadata and the z-interpolated movie
infoStruct = pipe.io.sbxInfo(sbxPath, true); %<-----Jun: I added a true to force it overwrite the info
Nchan = infoStruct.nchan;
Nplane = size(infoStruct.otwave,2);%<------Jun: when it is single plane, here may have problem.
Nscan = floor(infoStruct.nframes / numel(infoStruct.otwave)); %<------Jun: when it is single plane, here may have problem. And to avoid float number, I add floor here.
Nx = infoStruct.sz(1); %NxCrop = infoStruct.sz(1) - edges(3) - edges(4);
Ny = infoStruct.sz(2); %NyCrop = infoStruct.sz(2) - edges(1) - edges(2);

% Define the reference volume
if isempty(refScan), refScan = ceil(Nscan/2)-25:ceil(Nscan/2)+25; end  % JUn: use +/- 25 around middle frame as refscan
fprintf('\nUsing reference scans %i - %i', refScan(1), refScan(end));

% Use the z-interpolated projections as the reference
fprintf('\n     Loading %s', refPath); 
refMean = loadtiff( refPath );  % interpProjPath 

if Nchan == 1
    refChan = 1;
    NrefScan = numel(refScan);  refStack = zeros(Nx, Ny, Nplane, NrefScan);  refVol = zeros(Nx, Ny, Nplane);
    for z = flip(1:Nplane)
        refStack(:,:,z,:) = WriteSbxPlaneTif(sbxPath, z, 'firstScan',refScan(1), 'Nscan',NrefScan );
        nonBlankFrames = find(squeeze( sum( sum( refStack(:,:,z,:), 1), 2) ))'; 
        if numel(nonBlankFrames) ~= NrefScan, fprintf('\nExcluding %i blank frames from reference mean (z = %i)', NrefScan - numel(nonBlankFrames), z); end
        refVol(:,:,z) = mean( refStack(:,:,z,nonBlankFrames), 4); % exclude blank frames from averaging
    end
    if isempty(edges), edges = GetEdges( refMean(:,:,end), 'minInt', minInt, 'max', edgeMax, 'show', true ); end
    refVol = mean(refStack(edges(3)+1:end-edges(4), edges(1)+1:end-edges(2),:,:), 4);  % refMean(edges(3)+1:end-edges(4), edges(1)+1:end-edges(2), :)
else
    if refChan == 0
        fprintf('\nRGB data, using red channel for registration');
        refChan = 2;
    end
    chanSwitch = [2,1];
    if isempty(edges), edges = GetEdges( refMean(:,:,1,end), 'minInt', minInt, 'max', edgeMax, 'show', true ); end
    refVol = squeeze( refMean(edges(3)+1:end-edges(4), edges(1)+1:end-edges(2),chanSwitch(refChan), :) );
end
refVol = pipe.proc.binxy(refVol, scaleFactor); 
saveastiff( squeeze(uint16(refVol)), sprintf('%s%s%s_affineRef.tif', fDir, fSep, fName) );

% Check if data has been partially analyzed and pick up where it left off 
if exist( tformPath, 'file' ) && ~overwrite
    load( tformPath, 'tforms_all', 'edges', 'scaleFactor' );
    zReg = find( any( cellfun(@isempty, tforms_all), 2 ) )';
    if ~isempty(zReg),  fprintf('\n   %s already exists - finishing off from z = %i', tformPath, zReg(1) ); end
else
    zReg = 1:Nplane;
    tforms_all = cell(Nplane,Nscan); 
end

%register one z plane at a time to the appropriate z plane of the reference volume
fix(clock)
fprintf('\n');
for z = zReg
    fprintf('Registering plane %d of %d...  ',z, Nplane);
    tic
    tforms_all(z,:) = pipe.reg.turboreg(refVol(:,:,z), 'mov_path',sbxPath, 'optotune_level',z, 'nframes',Nscan, 'binxy',scaleFactor, 'edges',edges, 'pmt',refChan, 'highpass',false);
    toc
    save(tformPath,'tforms_all', 'edges', 'scaleFactor', '-mat');
end

% Apply the transforms and generate sbx_affine
tic
w = waitbar(0,'writing .sbx\_affine');
rw = pipe.io.RegWriter(sbxPath,infoStruct,'.sbx_affine',true);
if Nchan == 1
    fprintf('\n     Writing monochrome affine-registered sbx file'); 
    aff_chunk = zeros(Nx, Ny, Nplane);
    for s = 1:Nscan
        % Apply affine transformation to each plane of the scan
        interp_chunk = pipe.imread(sbxPath, Nplane*(s-1)+1, Nplane, refChan, []);
        for z = 1:Nplane % parfor is actually slower
            aff_chunk(:,:,z) = imwarp(interp_chunk(:,:,z), tforms_all{z,s}, 'OutputView',imref2d([Nx,Ny]));
        end
        % Write the results to sbx_affine
        rw.write(squeeze(uint16(aff_chunk))); %rw.write(squeeze(uint16(tempScan)));
        waitbar(s/Nscan, w);
    end
else
    fprintf('\n     Writing two-color affine-registered sbx file'); 
    for s = 1:Nscan
        interp_chunk = pipe.imread(sbxPath, Nplane*(s-1)+1, Nplane, -1, []); %raw_scan = pipe.imread(path, Nplane*(s-1)+1, Nplane, -1, []);
        interp_chunk = interp_chunk(:,edges(3)+1:end-edges(4), edges(1)+1:end-edges(2),:);
        interp_chunk = reshape(interp_chunk, Nchan, NxCrop, NyCrop, Nplane, []);
        trans_scan = zeros( Nchan, NxCrop, NyCrop, Nplane );
        for c = 1:2
            for z = flip(1:Nplane)
                trans_scan(c,:,:,z) = imwarp( squeeze(interp_chunk(c,:,:,z)), tforms_all{z,s}, 'OutputView',imref2d(size(interp_chunk,[2,3]))); 
            end
        end
        % Write to sbx_affine
        tempScan = zeros(2, Nx, Ny, Nplane, 'uint16');
        tempScan(:,edges(3)+1:end-edges(4), edges(1)+1:end-edges(2),:) = trans_scan;
        rw.write( tempScan ); % rw.write(squeeze(uint16(tempScan)));
        waitbar(s/Nscan, w);
    end
end
rw.delete;
close(w);
toc

end

% Assemble the aligned data into a new volume scan movie
%{
fprintf('\n     Assembling affine aligned movie and writing sbx_affine');
tic
aff_chunk = zeros(Nx, Ny, Nplane);
w = waitbar(0,'writing .sbx\_affine');
rw = pipe.io.RegWriter(sbxPath,infoStruct,'.sbx_affine',true);
for s = 1:Nscan
    % Apply affine transformation to each plane of the scan
    interp_chunk = pipe.imread(sbxPath, Nplane*(s-1)+1, Nplane, refChan, []);
    for z = 1:Nplane % parfor is actually slower
        aff_chunk(:,:,z) = imwarp(interp_chunk(:,:,z), tforms_all{z,s}, 'OutputView',imref2d([Nx,Ny]));
    end
    % Write the results to sbx_affine
    rw.write(squeeze(uint16(aff_chunk))); %rw.write(squeeze(uint16(tempScan)));
    waitbar(s/Nscan, w);
end
rw.delete;
close(w);
toc
%}
%{
% Compare results from different affine reg paramter settings
oldDeform = struct('trans_x',[], 'trans_y',[], 'scale_x',[], 'scale_y',[], 'shear_x',[], 'shear_y',[]);
for z = 19 %10 %1:Nplane
    for s = 1:Nscan
        oldDeform.trans_x(s) = tforms_all{z,s}.T(3,1);
        oldDeform.trans_y(s) = tforms_all{z,s}.T(3,2);
        oldDeform.scale_x(s) = tforms_all{z,s}.T(1,1);
        oldDeform.scale_y(s) = tforms_all{z,s}.T(2,2);
        oldDeform.shear_x(s) = tforms_all{z,s}.T(1,2);
        oldDeform.shear_y(s) = tforms_all{z,s}.T(2,1);
    end
end

% Try using scaleFactor = 1
tic
scale1_tforms = cell(1,600); 
scale1_tforms(1,:) = pipe.reg.turboreg(refVol(:,:,z), 'mov_path',sbxPath, 'optotune_level',z, 'nframes',600, 'binxy',scaleFactor, 'edges',edges, 'pmt',refChan);
toc
for s = 1:600
    scale1Deform.trans_x(s) = scale1_tforms{1,s}.T(3,1);
    scale1Deform.trans_y(s) = scale1_tforms{1,s}.T(3,2);
    scale1Deform.scale_x(s) = scale1_tforms{1,s}.T(1,1);
    scale1Deform.scale_y(s) = scale1_tforms{1,s}.T(2,2);
    scale1Deform.shear_x(s) = scale1_tforms{1,s}.T(1,2);
    scale1Deform.shear_y(s) = scale1_tforms{1,s}.T(2,1);
end

% Try using scaleFactor = 2 (original), with preregistration
tic
prereg_tforms = cell(1,600); 
prereg_tforms(1,:) = pipe.reg.turboreg(refVol(:,:,z), 'mov_path',sbxPath, 'optotune_level',z, 'nframes',600, 'binxy',scaleFactor, 'edges',edges, 'pmt',refChan, 'pre_register',true);
toc
for s = flip(1:600)
    preregDeform.trans_x(s) = prereg_tforms{1,s}.T(3,1);
    preregDeform.trans_y(s) = prereg_tforms{1,s}.T(3,2);
    preregDeform.scale_x(s) = prereg_tforms{1,s}.T(1,1);
    preregDeform.scale_y(s) = prereg_tforms{1,s}.T(2,2);
    preregDeform.shear_x(s) = prereg_tforms{1,s}.T(1,2);
    preregDeform.shear_y(s) = prereg_tforms{1,s}.T(2,1);
end

% Try using scaleFactor = 2 AND no high pass filtering
tic
nohp_tforms = cell(1,600); 
nohp_tforms(1,:) = pipe.reg.turboreg(refVol(:,:,z), 'mov_path',sbxPath, 'optotune_level',z, 'nframes',600, 'binxy',scaleFactor, 'edges',edges, 'pmt',refChan, 'highpass',false);
toc
for s = flip(1:600)
    nohpDeform.trans_x(s) = nohp_tforms{1,s}.T(3,1);
    nohpDeform.trans_y(s) = nohp_tforms{1,s}.T(3,2);
    nohpDeform.scale_x(s) = nohp_tforms{1,s}.T(1,1);
    nohpDeform.scale_y(s) = nohp_tforms{1,s}.T(2,2);
    nohpDeform.shear_x(s) = nohp_tforms{1,s}.T(1,2);
    nohpDeform.shear_y(s) = nohp_tforms{1,s}.T(2,1);
end
% Try using scaleFactor = 1 AND no high pass filtering
tic
sc1nohp_tforms = cell(1,600); 
sc1nohp_tforms(1,:) = pipe.reg.turboreg(refVol(:,:,z), 'mov_path',sbxPath, 'optotune_level',z, 'nframes',600, 'binxy',scaleFactor, 'edges',edges, 'pmt',refChan, 'highpass',false);
toc
for s = flip(1:600)
    sc1nohpDeform.trans_x(s) = sc1nohp_tforms{1,s}.T(3,1);
    sc1nohpDeform.trans_y(s) = sc1nohp_tforms{1,s}.T(3,2);
    sc1nohpDeform.scale_x(s) = sc1nohp_tforms{1,s}.T(1,1);
    sc1nohpDeform.scale_y(s) = sc1nohp_tforms{1,s}.T(2,2);
    sc1nohpDeform.shear_x(s) = sc1nohp_tforms{1,s}.T(1,2);
    sc1nohpDeform.shear_y(s) = sc1nohp_tforms{1,s}.T(2,1);
end

compDeform1 = nohpDeform;sc1nohpDeform; %
compDeform2 = sc1nohpDeform;
figure('WindowState','maximized');
sp(1) = subplot(6,1,1);
%plot( oldDeform.trans_x ); hold on;
plot( compDeform1.trans_x ); hold on;
plot( compDeform2.trans_x ); 
ylabel('X Trans');
sp(2) = subplot(6,1,2);
%plot( oldDeform.trans_y ); hold on;
plot( compDeform1.trans_y ); hold on;
plot( compDeform2.trans_y ); 
ylabel('Y Trans');
sp(3) = subplot(6,1,3);
%plot( oldDeform.scale_x ); hold on;
plot( compDeform1.scale_x ); hold on;
plot( compDeform2.scale_x ); 
ylabel('X Scale');
sp(4) = subplot(6,1,4);
%plot( oldDeform.scale_y ); hold on;
plot( compDeform1.scale_y ); hold on;
plot( compDeform2.scale_y ); 
ylabel('Y Scale');
sp(5) = subplot(6,1,5);
%plot( oldDeform.shear_x ); hold on;
plot( compDeform1.shear_x ); 
plot( compDeform2.shear_x ); 
ylabel('X Shear');
sp(6) = subplot(6,1,6);
%plot( oldDeform.shear_y ); hold on;
plot( compDeform1.shear_y ); hold on;
plot( compDeform2.shear_y ); 
ylabel('Y Shear');
linkaxes(sp, 'x')
xlim([1,600]);

%}
