function registrate_cross_trials(animal, date, runs, savepath)

for i = 1:length(runs)
    p = load_parameters(animal, date, runs(i));
    shiftPara = load(p.registration_parameter_path);
    % xyshift(i,1:4) = shiftPara.superRef_xyshift;
    
    if i == 1
        mx = loadTiffStack_slow(p.pretreated_mov);
        ref = reshape(squeeze(mean(mx, 4)), [size(mx,1),size(mx,2),size(mx,3),1]);
        lengthlist = [size(mx,4)];
    else
        tmp = loadTiffStack_slow(p.pretreated_mov);
        ref(:,:,1,i) = squeeze(mean(tmp, 4));
        mx = cat(4, mx, tmp);
        lengthlist = [lengthlist, size(tmp, 4)];
    end
end

[r,c,ch,f] = size(mx);
idxlist = [0];
for i = 1:length(lengthlist)
    idxlist = [idxlist, lengthlist(i)+idxlist(end)];
end

% Super ref: Perform registration to refs
errMx = zeros(size(ref,4));
for i = 1:size(ref,4)
    refFT = fft2(ref(:,:,1,i));
    for j = 1:size(ref,4)
        indFT = fft2(ref(:,:,1,j));
        [output, tmp] = dftregistration( refFT, indFT, upscale );
        errMx(i,j) = output(1);
    end
end

[tmp,refidx] = min(mean(errMx,2));
superref = fft2(ref(:,:,1,refidx));

superShift = nan(f, 5);
for i = 1:size(ref,4)
    indFT = fft2(ref(:,:,1,i));
    [output, tmp] = dftregistration(superref, indFT, upscale );
    sid = idxlist(i)+1;
    eid = idxlist(i+1);
    superShift(sid:eid,1) = output(4); 
    superShift(sid:eid,2) = output(3); 
    superShift(sid:eid,3) = norm(output(3:4)); 
    superShift(sid:eid,4) = output(1); 
    superShift(sid:eid,5) = output(2);
    
end

for i = 1:ch
    regMovie(:,:,i,:) = apply_shift(mx(:,:,i,:), superShift);
end

superRef = uint16(squeeze(mean(regMovie(:,:,p.config.registratePmt+1,:), 4)));
regMovie = uint16(regMovie);

superRef_xyshift=[min(superRef_xyshift(:,1)), max(superRef_xyshift(:,2)), min(superRef_xyshift(:,2)), max(superRef_xyshift(:,2))]*upscale;

if ~strcmp(shift_file_name, '')
    save(shift_file_name, 'superShift', 'ref', 'superRef', 'superRef_xyshift');
end

mx2tif(regMovie, savepath);

fprintf('  Done.   ');
    

end