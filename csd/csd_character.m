function character = csd_character(array)

analysis_duration = 150;

array = smooth(array, 15);
character = struct();
[character.peakvalue, character.peakidx] = max(array);

% find the low point before peak
tmparray = flip(array(1 : character.peakidx));
tmparray = tmparray(2:end) - tmparray(1:end-1);
csd_start_point = find(tmparray > 0);
csd_start_point = character.peakidx - csd_start_point(1);

tmparray = array(character.peakidx : end);
tmparray = tmparray(2:end) - tmparray(1:end-1);
csd_end_point = find(tmparray > 0);
csd_end_point = csd_end_point(1) + character.peakidx -1;

character.csd_start_point = csd_start_point;
character.csd_end_point = csd_end_point;




end