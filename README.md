# pandapenguin
This repo contains multiple tools for two photon experiment and data analysis.
In the root folder, it contains the functions almost necessary all kinds of two photon experiments.
For each experiment, you need first of all copy a config.yml to each experiment folder (run). This file defines whether the signal need denoise, registration, and which function you need to use, and also some fundmental paramerters related with these steps. You can either copy manually or use build_config function to copy config.yml to a series of runs.
If you need to do registration, you need to run build_registration_ref to create ref.tif for each experiment run. 
After you copy config.yml to experiment folder and make some revise, and possiblly finished build ref for registration, you can use load_parameters to load parameters for pretreatment by running treatsbx. This will output a XXX_XXX_XXX_pretreated.tif. This file will be ready to do further analysis.
besides the fundamental function, all pretreat functions are in pretreat folder.


================================================================================
### 1. vessel_diameter_measurement
scripts used for 2P experiment vessel diameter measurement


diameter.m
This function calculate blood vessal diameter value (unit is pixal) changes. In two photon experiment we can label the blood vessal by injecting dye like dextran red. diameter.m need two input values, path is the tif movie path. has label is whether your blood vessal be labeled by dye or not. For artery, its wall has auto fluorocent. it lights up even you don't give dye. 

findedge.m
the algorithem to find the blood vessal edge.

findedge_nonlabel.m
the algorithem to find the not dyed blood vessal edge.


================================================================================
### 2. astrocyte calcium signal analysis
Tools used to process astrocyte calcium signal. The tools are mainly designed for astrocyte in rat animal as the signal noise ratio is much lower than mouse. 
