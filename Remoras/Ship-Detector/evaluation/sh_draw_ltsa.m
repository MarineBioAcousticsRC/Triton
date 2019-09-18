function sh_draw_ltsa(handles)
%
% sh_eval_draw_ltsa.m
%
% Plot ltsa sessions using detections to define sessions  

ltsa = handles.ltsa;

% Get power spectral density of the ltsa
pwr = ltsa.pwr;

% Change plot frequency axis
%%%% Initializa value somewhere
handles.StartFreqVal = 0;
handles.EndFreqVal = ltsa.fmax;

[~,low] = min(abs(ltsa.freq-handles.StartFreqVal));
[~,high] = min(abs(ltsa.freq-handles.EndFreqVal));
% pwr = pwr(ltsa.fimin:ltsa.fimax,:); %fimin=1 | fimax = 1001
pwr = pwr(low:high,:); %fimin=1 | fimax = 1001



