function plot_csd_array(array, character)

f = length(array);
plot(1:f, array, '-', 'color', 'blue');
hold on;
tmp = array(character.csd_start_point:character.csd_end_point);
f = length(tmp);
plot(character.csd_start_point:character.csd_start_point+f, tmp, '-', 'color', 'red');


end