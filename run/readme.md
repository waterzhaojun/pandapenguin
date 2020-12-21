12/20/2020
The main function in this folder is :
running_analysis: the main function to get running data.
run_config: set parameters.
run_file_system: the structure of the output running folder.


Several related functions to get running bout.
boutFilter: This function is to filter out the bouts we got.
deshake: remove shaking created quad data.

12/4/2020
When we get the quan array, we first transfer it to speed (by diff). Because some time when animal stay at the wheel, the bar go up and down across the LED which produce a lot 1,-2 loop. So we need to deshake this 1,-1 noise. The deshaked array will be bint to 1hz to decide whether it is running or not. We define a running bout need to run at least 2 sec continuously. The running bout gap between should no more than 2 sec, otherwise they will be connected together. When we get from when to when the animal is running, we zoom in to original array to check at which idx it really start to run and which idx to stop. The a series of analysis will be done based on this bout array. These characters include:
. startsec: at which second it starts to run
. endsec: at which second it stops
. startidx: at which idx of the original array it starts to run
. endidx: at which idx of the original array it stops
. array: the bout array from startidx to endidx
. distance: how many blocks this bout crossed. It is the sum of the absolute value of array. You need to multiple block gap if you need get real distance.
. duration: How many seconds this bout lasts. The unit is sec which is calcuated based on scanrate.
. speed: the average speed of this bout. It is the distance / duration. You need to multiple block gap if you need get real speed.
. direction: If the sum of array less or equal than 0, it is -1 means backward movement. otherwise it is 1 means forward movement.
. maxspeed: the max of speed.
. acceleration: we bint the array absolute value to 1hz, than calcuate diff of this array to get the accelate of each sec. the max value was used as acceleration for this bout.
. acceleration_delay: the second delay from start of the bout to get the max acceleration.

