function sm_cmpt_timeinc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_cmpt_timeinc.m
% 
% initialize output time increments dependent on user choices
% for averaging time from start to end of deployment
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA PARAMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% find start and end time of deployment
% start time
PARAMS.ltsa.inpath = REMORA.sm.cmpt.PathList{1};
PARAMS.ltsa.infile = REMORA.sm.cmpt.FileList{1};
sm_read_ltsahead;
datestart = PARAMS.ltsa.dvecStart(1,:);

% end time
PARAMS.ltsa.inpath = REMORA.sm.cmpt.PathList{end};
PARAMS.ltsa.infile = REMORA.sm.cmpt.FileList{end};
sm_read_ltsahead;
dateend = PARAMS.ltsa.dvecEnd(end,:);

%% align bin size of averaging window with full hours

% floor to full hour
datestart(5:6) = 0;
dateend(5:6) = 0;
% add last hour to dateend
dateend(4) = dateend(4) + 1;

% make time vector based on averaging time (in seconds) for full deployment
avgt = REMORA.sm.cmpt.avgt;

timebins = (datenum(datestart)*24*60*60):avgt:(datenum(dateend)*24*60*60);
REMORA.sm.cmpt.avgbins = (timebins/24/60/60).';


