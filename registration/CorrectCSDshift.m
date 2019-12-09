function [shift, CSDframes] = CorrectCSDshift(shift)
% This file is based on Andy's same name file. 
% When the ori repo updated, please copy the edited part to updated file.

% shift = shift values obtained from registration of unregMovie, using dftregistration. organized as (Nframe x 5 x 3)array of [ xshift, yshift, shift distance, error, phase difference ]


corrShift = shift(:,[1:2,5]); 
shiftthreshold = 3;

CSDframes = find( sum( abs(zscore( shift(:,1:2) )) > shiftthreshold, 2) ); % <=============use shiftthreshold
fprintf('\nFound %i CSD-related frames from %i. ', numel(CSDframes), length(shift));

if numel(CSDframes) > 0
    goodFrame = 1:size(shift,1);  goodFrame( CSDframes ) = [];
    % Use interpolation to correct shifts
    corrShift(CSDframes, 1) = interp1( goodFrame, shift(goodFrame,1), CSDframes, 'spline' ); % x shift
    corrShift(CSDframes, 2) = interp1( goodFrame, shift(goodFrame,2), CSDframes, 'spline' ); % y shift
    %corrShift(CSDframes, 3, c) = interp1( goodFrame, shift(goodFrame,5,c), CSDframes, 'spline' ); % phase shift - better to leave this one uncorrected

    % deleted Plot part ========================================

    % Update values of shift array 
    shift(CSDframes,1:2) = corrShift(CSDframes,1:2);
    shift(CSDframes,3) = sqrt( corrShift(CSDframes,1).^2 + corrShift(CSDframes,2).^2 );
    shift(CSDframes,4) = NaN; % after the correction, we don't know the new image error

end

end

