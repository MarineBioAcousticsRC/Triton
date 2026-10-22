% How to extract Dtag3 data
% Jhildebrand 1-24
% 
% directory L:\GG_Tags\test
% 
% first run d3read on the .dtg file
% rename .wav files using cue times in .xml (see readme)
% file file libexpat.dll must be in the same directory
spec = 'zc';
tagnum = '210';
yr = '13';
fnamebase = 'zc210a';
depname= [spec, yr, '_', tagnum, 'a'];
filepath = ['E:\AcousticTags\data\Zc_Tags\',depname,'\']; 
% 
% Notify Matlab of where processed data should be stored. 
settagpath('cal','E:\AcousticTags\data\Zc_Tags\zc13\zc13_210a\cal','prh','E:\AcousticTags\data\Zc_Tags\zc13\zc13_210a\prh') 
%Read the sensor data:

X = d3readswv(filepath,fnamebase,10);
%df is the decimation factor, use 10

[ch_names,descr] = d3channames(X.cn); % get the channel names

%Register the deployment:
CAL = d3deployment(filepath,fnamebase,depname);
%
% If CAL is empty:
% [CAL,D] = d3deployment(filepath,fnamebase,depname);
%[CAL,id,cname] = d3findcal('49031937');
% 
% Optimize the pressure calibration:
[p,CAL]=d3calpressure(X,CAL,'full');
%
% Optimize the acceleration calibration:
[A,CAL,fs] = d3calacc(X,CAL,'full',10) ;
% min_depth take to use 10 m
% 
% Optimize the magnetometer calibration:
[M,CAL] = d3calmag(X,CAL,'full',10) ;
% 
% Save the calibration information so far to the deployment CAL file:
d3savecal(depname,'CAL',CAL)

% Estimeate orientation of tag on whale
% using  prhpredictor to generate an orientation table (OTAB)
% Two methods are supported:
%        Method 1 is suitable for logging-diving animals, e.g. sperm whales
%                 This is the default method.
%        Method 2 is suitable for whales that make short dives while
%        respiring, e.g., beaked whales.
%  TH = threshold, e.g. 10 
 PRH = prhpredictor(p,A,fs,[200,2,'both']); %TH = 500m is default
 OTAB = [PRH(1,1) 0 PRH(1,2) PRH(1,3) PRH(1,4); 
     PRH(2,1) PRH(5,1) PRH(5,2) PRH(5,3) PRH(5,4);]; % tag slipped for entire duration.


 %AJL OTAB NOTES:
 % OTAB = [move1, move2, move3...]
 % move_n = [t1 t2 p0 r0 h0]  (t1/t2= start/end mvmnt time, p/r/h0=
 % pitch/roll/heading of movement
 % First row MUST be initial position (PRH row 1)
 % Subsequent rows are points in PRH where any combo of p0,r0,h0 are
 % significantly different. Adjust code as needed.
 % t2=0 here b/c time when tag slipped is unknown.                                                                                            
% 
% Test the OTAB by creating the whale frame acceleration signals: 
  [Aw,Mw] = tag2whale(A,M,OTAB,fs);

%Save the OTAB for the deployment
 d3savecal(depname,'OTAB',OTAB)

% Apply the calibration at different sensor sampling rates as required.
d3makeprhfilecopy(filepath,'zc210a',depname,10) %use d3makeprhfilecopy to include tempr variable for MTViewer
% 
% 
% NOT CLEAR BELOW IS NEEDED
% settagpath('audio','L:\GG_Tags\test') % add raw directory to paths
% [s,fs] = swvread('gg216a001') ; % read the .swv files
% saveraw('gg216a001',s,fs) % save a raw file
% 
% settagpath('prh','L:\GG_Tags\test\phr') % add prh directory to paths
% [s,fs] = loadraw(tag) ; % if workspace was cleared after step 5
% CAL= tag216 ; % read the calibration for the device use
% 
% [p,tempr,CAL] = calpressure(s,CAL,'full') ; % follow screen directions