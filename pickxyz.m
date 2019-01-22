function pickxyz(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% pickxyz.m
%
% Called with each mouse button click down in Plot Window
% ie. WindowButtonDownFcn callback for HANDLES.fig.main
%
% Selections are used for:
%   expanding LTSAs
%   displaying pickxyz values the Message Window - poorman's logger
%   selecting items for added Remoras (ie Logger, Hello World)
%   displaying cursor position (coorddisp) in Message Window
%       when none of the above selected
%
% When multiple items are possible, only the first one executed per order
% above.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS REMORA

selectiontype = get(HANDLES.fig.main,'SelectionType');
PARAMS.pick.button.value = get(HANDLES.pick.button,'Value');
PARAMS.expand.button.value = get(HANDLES.ltsa.expand.button,'Value');

% turn on/off cross hairs
if PARAMS.pick.button.value || PARAMS.expand.button.value
    set_pointer(HANDLES.fig.main, 'fullcross');
else
    set_pointer(HANDLES.fig.main, 'arrow');
end

if (nargin == 1 && varargin{1} == true) || ...
        (nargin == 3 && ishandle(varargin{1}) && varargin{3} == true)
    % Not a callback, the use just wanted the cursor set
    return
end

if strcmp(selectiontype, 'alt')
    % Alternate selection - shift click
    return  % We are not doing anything with alternate selections yet
end

savalue = get(HANDLES.display.ltsa,'Value');    % is the LTSA active?

% check to see if selections have been made and execute accordingly
if PARAMS.expand.button.value  && savalue && ... % LTSA expand if clicked in LTSA plot
        (gco == HANDLES.subplt.ltsa || gco == HANDLES.plt.ltsa)
    set_pointer(HANDLES.fig.main, 'fullcross');
    pickxwav
    % turn on channel changer to correct channel selection
    set(HANDLES.ch.pop,'Value',PARAMS.ch)
elseif PARAMS.pick.button.value % display pickxyz in Message Window
    set_pointer(HANDLES.fig.main, 'fullcross');
    if isempty(gco)
        % callback not associated with any object
        % Can reliably reproduce when clicking on colorbar label,
        % it's not clear why this happens.
        return;
    end
    % coorddisp returns the information about where the cursor is.
    info_struct = coorddisp(1); % 1 indicates not a callback, want a return value
    % Only process selection if we have a valid time or frequency
    if info_struct.proc % it will be 0 if nothing was calculated
        if PARAMS.pick.button.value
            MultiCh_On = get(HANDLES.mc.on,'Value');
            MultiCh_Off = ~MultiCh_On;
            if MultiCh_On
                for ch = 1+savalue:PARAMS.nch+savalue
                    handle_num = eval(sprintf('HANDLES.axes%d.handle',ch));
                    if handle_num == gca
                        ch_num = eval(sprintf('HANDLES.axes%d.ch',ch));
                        if savalue
                            ch_num = ch_num - 1;
                        end
                    end
                end
                switch info_struct.plot
                    case 'ts'
                        str = sprintf('%s Counts %d  Channel %d', info_struct.time,...
                            info_struct.count, ch_num);
                    case 'sp'
                        str = sprintf('%s   %d Hz   %0.1f dB  Channel %d',  info_struct.time,...
                            round(info_struct.freq), info_struct.db, ch_num);
                    case 'sg'
                        str = sprintf('%s    %d Hz   %0.1f dB  Channel %d', info_struct.time,...
                            info_struct.freq, info_struct.db, ch_num);
                    case 'sa'
                        str = sprintf('%s   %d Hz   %0.1f dB',  info_struct.time,...
                            info_struct.freq, info_struct.db);
                end
            elseif MultiCh_Off
                switch info_struct.plot
                    case 'ts'
                        str = sprintf('%s Counts %d', info_struct.time, info_struct.count);
                    case 'sp'
                        str = sprintf('%s   %d Hz   %0.1f dB',  info_struct.time,...
                            round(info_struct.freq), info_struct.db);
                    case 'sg'
                        str = sprintf('%s    %d Hz   %0.1f dB', info_struct.time,...
                            info_struct.freq, info_struct.db);
                    case 'sa'
                        str = sprintf('%s   %d Hz   %0.1f dB',  info_struct.time,...
                            info_struct.freq, info_struct.db);
                end
            end
            disp_pick([str,' ', info_struct.plot]);
        end
    end
    
elseif REMORA.pick.value > 0    % select items for Remora(s)
    for k = 1:REMORA.pick.value
        eval(char(REMORA.pick.fcn{k}));
    end
    
else      % display curror position xyz in Message Window
    coorddisp(0); % 0= just display xyz in Message Window, no structure
end

end


