=======================================================================================================================================================
=======================================================================================================================================================
=======================================================================================================================================================
build_registration_para: Each big mx need to seperate to small pieces. This function is to help you decide the idx and seperate to small pieces by the indexes.

build_csd_registration_para: For csd movie, the piece need to be smaller. This function is to seperate it based on the csd array.

=======================================================================================================================================================
=======================================================================================================================================================
=======================================================================================================================================================

dft_xxx
This series of files use dft as registration method. 
=================================================================================================
dft_190928: As to today this is the method used for registration.

dft_piece_registration: This method mainly used to registrate ref pics. It choose one frame as ref and registrate the others based on this.

dft_trunk_registration: This method first build a ref by using mean along the frames. then registrate each frame based on it.

dft_expand_shift: shift and supershift have different frames. This function is to expand supershift to let it has same frames as shift.

dft_apply_shift: apply shift to original mx to create registrated mx.

dft_clean_edge: based on the registrated mx and shift, crop the edge. If you have multiple steps registration, add shifts together then apply.


=======================================================================================================================================================
=======================================================================================================================================================
=======================================================================================================================================================