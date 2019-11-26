function character = csd_character(array)

% nalysis_duration = 150;
impossible_csd_period = 70 *15; %csd can't happen in 70 sec

array = smooth(array, 45);
character = struct();
[character.peakvalue, character.peakidx] = max(array);

if character.peakidx < impossible_csd_period
    [character.peakvalue, character.peakidx] = max(array(impossible_csd_period:end));
    character.peakidx = character.peakidx + impossible_csd_period-1;
end

% find the low point before peak
tmparray = flip(array(1 : character.peakidx));
tmparray = tmparray(2:end) - tmparray(1:end-1);
csd_start_point = find(tmparray > 0);
csd_start_point = character.peakidx - csd_start_point(1)+1;

tmparray = array(character.peakidx : end);
tmparray = tmparray(2:end) - tmparray(1:end-1);
csd_end_point = find(tmparray > 0);
csd_end_point = csd_end_point(1) + character.peakidx -1;

character.csd_start_point = csd_start_point;
character.csd_end_point = csd_end_point;

smoothwindow = 1800;
tmparray = smooth(array(character.csd_end_point:end), smoothwindow);

character.a2_endpoint = checkwindow(tmparray) + character.csd_end_point - 1;




end