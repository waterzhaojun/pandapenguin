cedpath = 'C:\CEDMATLAB\CEDS64ML'; % if no environment variable (NOT recommended) 
cedpath = getenv('CEDS64ML');         % if you have set this up (this is the recommende 
addpath( cedpath );                   % so CEDS64LoadLib.m is found 
CEDS64LoadLib( cedpath );             % load ceds64int.dll 

fhand1 = CEDS64Open( 'E:\jzhao electrophysiology\151020 CSD FLCT topic\mech-Oct-20-15-14-36-1058.smr' ); 
if (fhand1 <= 0); unloadlibrary ceds64int; return; end


maxTimeTicks = CEDS64ChanMaxTime( fhand1, 1 )+1; % +1 so the read gets the last point 
[ fRead, fVals, fTime ] = CEDS64ReadWaveF( fhand1, 1, 1000000, 0, maxTimeTicks );


fVals = csvread('C:\Users\Levylab\Downloads\lfp\lfp2018040401.csv');

params = struct();
params.tapers = [3,5];
params.Fs = 100;
params.fpass = [0,50];
params.pad = 0; % Increase this will make f more precisely seperated. But it won't change the distribution. For now I think default 0 
%params.err = [1, 0.05];
[S,f] = mtspectrumc( fVals, params );


params = struct();
params.tapers = [1000,5,1];
params.Fs = 100;
params.fpass = [0,50];
params.err = [1, 0.05];
movingwin=[1000,10];

[S,t,f,Serr] = mtspecgramc( fVals, movingwin, params );