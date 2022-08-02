function logpickOn
%
% logpickOn.m was stolen from Logger Triton 1.81 pickxyz.m to work with 
% Triton's new Remora (add-on) approach. This code is a link between 
% Triton 1.92 and the Remora software-package Logger
% This code is the REMORA.pick.fcn funciton in Logger Remora's initialize.m
% It is recommended to rebuild this interface to better suit the needs of
% Logger Remora.
%
% 150417 smw

global PARAMS HANDLES

if isempty(gco)
    % callback not associated with any object
    % Can reliably reproduce when clicking on colorbar label,
    % it's not clear why this happens.
    return;
end

% Grab information about current selection, time, freq, etc.
info_struct1 = coorddisp(1);

% Let user drag out bounding box (rubber band box)
oldptr = set_pointer(HANDLES.fig.main, 'crosshair');
extent = rbbox();
% Then pull out the second point of the box and determine whether or
% not the user dragged something out or just wants a point.
info_struct2 = coorddisp(1);
clickLTSA = false; %if clicked, will switch to true
if info_struct1.proc
    info_struct1.time_dnum(1:2) = [datenum(info_struct1.time_vec) datenum(info_struct2.time_vec)];
    if strcmp(info_struct1.plot, 'ts')
        info_struct1.freq = [];
        info_struct1.db = [];
    else
        info_struct1.freq(2) = info_struct2.freq;
        info_struct1.db(2) = info_struct2.db;
    end
    % LTSA active?
    savalue = get(HANDLES.display.ltsa,'Value');
    % See if user clicked in LTSA
    if savalue
        clickLTSA = (gco == HANDLES.subplt.ltsa || gco == HANDLES.plt.ltsa);
    end
end
if clickLTSA
    fname = fullfile(PARAMS.ltsa.inpath, PARAMS.ltsa.infile);
else
    fname = fullfile(PARAMS.inpath, PARAMS.infile);
end
set_pointer(HANDLES.fig.main, oldptr);
% Only process selection if we have a valid time or frequency
if info_struct1.proc
    if isfield(PARAMS, 'log') % check that a log is actually open 
        if ~isempty(PARAMS.log.pick)
            if ~ isempty(info_struct1.time_vec)
                log_pick(info_struct1.time_dnum, info_struct1.freq, fname); % inform logger of selection
            end
        end
    end
end