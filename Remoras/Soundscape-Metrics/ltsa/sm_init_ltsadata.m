function sm_init_ltsadata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_init_ltsadata.m
%
% initialize ltsa data 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES

PARAMS.ltsa.plotStartRawIndex = 1;
PARAMS.ltsa.plotStartBin = 1;

sm_read_ltsahead
%checks to see if the current end frequecy is bigger than the max frequency
%or if the this is the first LTSA being opened 

if PARAMS.ltsa.freq1 > PARAMS.ltsa.fmax || PARAMS.ltsa.freq1 < 0 %need to fix when changing current freq1 to new fmax
     PARAMS.ltsa.freq1 = PARAMS.ltsa.fmax; 
     PARAMS.ltsa.freq0 = 0;
end

% change plot freq axis
PARAMS.ltsa.fimin = ceil(PARAMS.ltsa.freq0 / PARAMS.ltsa.freq(2))+1;
PARAMS.ltsa.fimax = ceil(PARAMS.ltsa.freq1 / PARAMS.ltsa.freq(2) + 1);
PARAMS.ltsa.f = PARAMS.ltsa.freq(PARAMS.ltsa.fimin:PARAMS.ltsa.fimax);
set(HANDLES.ltsa.endfreq.edtxt,'String',PARAMS.ltsa.freq1);

% if PARAMS.ltsa.ver == 2 % commented out 4/30/2014
%     PARAMS.ch = PARAMS.ltsa.ch;
% end
% plot initial start time
PARAMS.ltsa.plot.dvec = PARAMS.ltsa.start.dvec;
PARAMS.ltsa.plot.dnum = PARAMS.ltsa.start.dnum;

% Initial times for both formats:
PARAMS.ltsa.save.dnum = PARAMS.ltsa.start.dnum;
PARAMS.ltsa.start.dvec = datevec(PARAMS.ltsa.start.dnum);


% turn on zoomin toggle button
set(HANDLES.ltsa.expand.button,'Visible','on')