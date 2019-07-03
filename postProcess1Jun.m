function postProcess1Jun(animalID, dateID, run)

    files = sbxDirJun(animalID, dateID, run);
    
    % speed part
    if isempty(files.runs{1}.speed) & ~isempty(files.runs{1}.quad)
        speed = sbxSpeed(animalID, dateID, run);
        save([files.runs{1}.sbx(1:end-3), 'speed'], 'speed');
    end
    disp('speed done');
    
    % eye part
    if isempty(files.runs{1}.eye) & ~isempty(files.runs{1}.eyeSource)
        pupil = sbxPupil(animalID, dateID, run);
        save([files.runs{1}.sbx(1:end-3), 'eye'], 'pupil');
    end
    disp('eye done');
    
    % alignment
    if ~exist(files.runs{1}.align)
        sbxAlignAffine(animalID, dateID, run);
    end
    disp('alignment done');
    
    % Get the distance moved determined from registration
    if isempty(files.runs{1}.brainmotion)
        brainmotion = registrationMovement(animalID, dateID, run);
        save([files.runs{1}.sbx(1:end-3), 'brainmotion'], 'brainmotion');
    end
    disp('brain motion done'); 
    
    % clean sbx
    if ~exist(files.runs{1}.cleansbx)
        sbxPCAClean(animalID, dateID, run);
    end
    disp('clean sbx done');
    
    % fiberMap related tif
    if ~exist(files.runs{1}.fiberMap)
        files = sbxDirJun(animalID, dateID, run);
        sbxClean = files.runs{1}.cleansbx;
        array = sbxReadPMT(sbxClean);
        maxFiberMap(array, files.runs{1}.path);
        disp('fiberMap done');
        %meanFiberMap = im2uint8(uint16(mean(array, 3)));
        %imwrite(meanFiberMap, [files.runs{1}.path, 'fiberMap_mean.tif']);
        
        % seems I don't need to set java path. 
        %javaaddpath 'C:\Program Files\MATLAB\R2016a\java\mij.jar';
        %javaaddpath 'C:\Program Files\MATLAB\R2016a\java\ij.jar';
        MIJ.start;
        IJ=ij.IJ(); 
        
        parSizeList = {'40-80'; '80-150'};
        firstRef = 1;
        for i = 1:length(parSizeList);
            IJ.open(java.lang.String([files.runs{1}.path, 'fiberMap.tif']));
            macro_text = ['setAutoThreshold("Default dark");'...
                'run("Analyze Particles...", "size=', parSizeList{i}, ' circularity=0.80-1.00 show=Masks exclude include");'...
                'run("Invert");'...
                'saveAs("Tiff", "', strrep(files.runs{1}.path, '\', '\\'), 'fiberMap_ref.tif', '");'...
                'close();'...
                'selectWindow("fiberMap.tif");'...
                'close();'...
            ];
            IJ.runMacro(macro_text);
            
            files = sbxDirJun(animalID, dateID, run);
            ref = loadFiberMap(files.runs{1}.bgBin);
            if length(ref)>0
                bgValue = xy3DValue(array, ref);
                if firstRef == 1
                    gf = goodFrames(bgValue);
                    firstRef = 0;
                else
                    gf = intersect(gf, goodFrames(bgValue));
                end
            end
        end
        
        save([files.runs{1}.sbx(1:end-3), 'goodFrames'], 'gf');
        disp('good frames done');
        goodFrameArray = meltWithGoodFrame(array, gf, 15);
        writetiff(goodFrameArray, [files.runs{1}.path, 'goodframemovie.tif']);
        disp('good frame movie done');
                
    end
    
    % background ref changes, used for goodFrames
    %if exist(files.runs{1}.bgBin) & isempty(files.runs{1}.refsignal)
    %    ref = loadFiberMap(files.runs{1}.bgBin);
    %    bgValue = xy3DValue(array, ref);
    %    save([files.runs{1}.sbx(1:end-3), 'refsignal'], 'bgValue');
    %end
    %disp('finished background calculation');
    

end