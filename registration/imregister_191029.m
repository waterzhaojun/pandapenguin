function [regmx, shift] = imregister_191029(mx, ref, shift_output, regPmt)

% So far this method is not good for noisy and event related astrocyte
% movie.

[optimizer, metric] = imregconfig('multimodal');

regmx = zeros(size(mx));
shift = zeros(size(mx, 4), 1);

if size(mx, 3) == 1, regPmt = 1; end

for i = 1:size(mx, 4)
    shift(i,1) = imregtform(squeeze(mx(:,:,regPmt,i)), ref, 'affine', optimizer, metric);
    regmx(:,:,regPmt, i) = imwarp(squeeze(mx(:,:,regPmt,i)), shift, 'OutputView', imref2d(size(ref)));
end

if ~strcmp(shift_output, '')
    save(shift_output, 'shift');
end

end