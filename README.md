# vessel_diameter_measurement
scripts used for 2P experiment vessel diameter measurement


diameter.m
This function calculate blood vessal diameter value (unit is pixal) changes. In two photon experiment we can label the blood vessal by injecting dye like dextran red. diameter.m need two input values, path is the tif movie path. has label is whether your blood vessal be labeled by dye or not. For artery, its wall has auto fluorocent. it lights up even you don't give dye. 

findedge.m
the algorithem to find the blood vessal edge.

findedge_nonlabel.m
the algorithem to find the not dyed blood vessal edge.
