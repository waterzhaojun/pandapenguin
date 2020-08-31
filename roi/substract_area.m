function newmask = substract_area(mask, na_area)

newmask = ((mask - na_area)>0)*1;
newmask = uint16(newmask);

end