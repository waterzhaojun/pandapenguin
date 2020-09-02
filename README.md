# pandapenguin
This repo contains multiple tools for two photon experiment and data analysis.
In the root folder, it contains the functions almost necessary all kinds of two photon experiments.
For each experiment, you need first of all copy a config.yml to each experiment folder (run). This file defines whether the signal need denoise, registration, and which function you need to use, and also some fundmental paramerters related with these steps. You can either copy manually or use build_config function to copy config.yml to a series of runs.
If you need to do registration, you need to run build_registration_ref to create ref.tif for each experiment run. 
After you copy config.yml to experiment folder and make some revise, and possiblly finished build ref for registration, you can use load_parameters to load parameters for pretreatment by running treatsbx. This will output a XXX_XXX_XXX_pretreated.tif. This file will be ready to do further analysis.
besides the fundamental function, all pretreat functions are in pretreat folder.

================================================================================
### data pretreatment
For each 2P experiment, pretreatment is always the No.1 necessary step. This step can be done by treatsbx.m which stored in the root folder. Right now it do multiple steps including load data, denoise, trim, registration and downsample. Except registration which contains a large group of choice, and have to store in a independent folder, others functions are stored in pretreat folder.
To use this function, some preparation is needed.

1. build_config.m: Each project has different pretreat method and parameters to use. For example, the aav expression is not good for specific animal in your project, so you have to pay much attention on denoise. Other project is observing different tissue which need a different registration method. For your specific project, you need a config.yml to define methods and parameters chose to use. You define a config.yml template. For each time you finished the experiments, you use build_config.m to copy the config.yml to each run folder. You may need to change the config.yml for some specific run as they might under treatment like CSD and need specific parameters.

2. some project has extra steps to set like for CSD project, you need to run related function to set registration seperate point, which will largely effect the registration result. Please check each project's note and run them before final pretreatment.

3. load_parameters.m: give the animalid, date, run, pmt(This parameter define which pmt data you want to load. If you leave it blank, it will only load pmt 0 which is green. If you recorded multiple pmts, better set it to [0,1] as it will registrate both channel at the same time)
The output of this function is a struct containing:
config_path: the config file path to pretreat the mx.
config: the config parameters when pretreat the mx. It should be the same as the file content.
refname: the reference file name when used to register the mx. For some reasom this file didn't saved in present folder, but you can find it stored in registration_parameter_path file(4/21/2020).
registration_parameter_path: This file stores a lot information related with registration like ref mx, the idx to seperate the chunk to registration.
registration_mx_path: this file is the registrated but not cropped mx. You can load it and crop the edge by regp = load(p.registration_parameter_path); mx = dft_clean_edge(mx, {regp.shift + regp.superShife}); then use.
pretreated_mov: the tif file converted from registration_mx_path file. it is registed but not cropped.



4. treatsbx.m: run give parameters to treatsbx.m, This is the step to do pretreatment. It finally output a movie named xxx_pretreated.tif. If we did registration, This movie will have noisy edge. This movie is just a reference, we can't use it for analysis. I need to search xxx_registrated_mx.mat and xxx_registrated_parameters.mat to get a clean movie based on which piece you want. So the best way is if exist xxx_registrated_mx.mat and xxx_registrated_parameters.mat, read them and clean_edge and downsample if necessary, if not exist, read xxx_pretreated.tif.

5. After pretreatment, you can go to your project folder to run specific analysis method to get the result.

6. In pretreat folder there are also some high level api for using. 
apply_shift.m is to apply mx with shift parameters. It is the same if you go to each registration function to apply, but this function will be easier.

================================================================================
### vessel_diameter_measurement
scripts used for 2P experiment vessel diameter measurement


diameter.m
This function calculate blood vessal diameter value (unit is pixal) changes. In two photon experiment we can label the blood vessal by injecting dye like dextran red. diameter.m need two input values, path is the tif movie path. has label is whether your blood vessal be labeled by dye or not. For artery, its wall has auto fluorocent. it lights up even you don't give dye. 

findedge.m
the algorithem to find the blood vessal edge.

findedge_nonlabel.m
the algorithem to find the not dyed blood vessal edge.


================================================================================
### astrocyte calcium signal analysis
Tools used to process astrocyte calcium signal. The tools are mainly designed for astrocyte in rat animal as the signal noise ratio is much lower than mouse. 
