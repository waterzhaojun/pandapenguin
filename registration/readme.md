As in 11/17/2019, I don't think I should cut the edge as if you want to connect all movies , the size will be different. Even you think it is not necessary to connect them to analysis, but I think it is always ok to cut afterwards.
registed_mx = dft_clean_edge(registed_mx, shift+superShife, 10);

A good thing for dft is if you want to do another register, you can just apply the shift to previous registed movie. So if you want to connect several trials, you just need grab each superref from each run, and registed them by dft_registrate_cross_trial and output a file named XXX_crosstrial_register_parameters. By apply this shift and cut the (shift + supershift + cross_trial_shift) edge.
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


==========================================================================================================Each file is registed by its own ref. The registration_parameter including :
ref_idx: all frames are seperated to multiple chunks. this array record at which frame they are broken.
shift: the shift based on each chunk's ref.
supershift: each chunk ref's shift based on super ref.
registed_ref: the registed each chunk's ref.
super_ref: It is the mean along the frames of registed whole mx (without cut the edge). So its edge is the mean of noisy edge, which means it is noisy but not that bad. But if you want a better cross trial registration result, you still need to registrate after cut the edge.

If you need regist cross trials, you need to use registreate_cross_trials and output a xxx_crosstrial_register_parameters file in each trial folder. it saves:
crosstrials: which runs used for cross trial register.
crosstrial_shift: the shift of this trial's superref.
registed_superref: the registed of this trial's superref. This superref has noisy edge. The size is the same as original mx.
If you want to use this cross trial registed mx, you need to load p.registration_mx_path and apply with crosstrial_shift. If for event analysis, cut the edge by (shift+superShift+crosstrial_shift). If for roi analysis, you don't need to cut the edge, just load registed_superref from xxx_crosstrial_register_parameters as roi map.
=======================================================================================================================================================
=======================================================================================================================================================