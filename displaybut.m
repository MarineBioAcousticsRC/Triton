function displaybut(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% displaybut.m
%
% Puts the desired plot on the display window
%
% Parameters:
%       action - a string that is the plot that you want displayed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS

% figure out how many subplots needed:
savalue = get(HANDLES.display.ltsa,'Value');
tsvalue = get(HANDLES.display.timeseries,'Value');
spvalue = get(HANDLES.display.spectra,'Value');
sgvalue = get(HANDLES.display.specgram,'Value');

MultiChValue = get(HANDLES.mc.on, 'Value');


m = savalue + tsvalue + spvalue + sgvalue ;  % total number of subplots

if strcmp(action,'timeseries')
    if MultiChValue
        set(HANDLES.display.spectra, 'Value', 0)
        set(HANDLES.tfradios,'Visible','off')
        set(HANDLES.display.specgram, 'Value', 0)
        control('ampoff')
        set(HANDLES.sgequal,'Visible','off')
        set(HANDLES.fax.linear, 'Visible', 'off')
        set(HANDLES.fax.log, 'Visible', 'off')
    end
    if tsvalue  % timeseries button on
        set(HANDLES.timeseriescontrol,'Visible','on')
        if PARAMS.nch > 1
            set(HANDLES.mc.on, 'Visible', 'on')
            %         set(HANDLES.mc.off,'Visible', 'on')
            if MultiChValue
                set(HANDLES.mc.lock,'Visible','on')
            end
        end
    elseif ~tsvalue % ts button off
        if ~sgvalue && ~spvalue
            set(HANDLES.mc.on, 'Visible', 'off')
            %          set(HANDLES.mc.off,'Visible', 'off')
            set(HANDLES.mc.lock,'Visible','off')
        end
        if ~sgvalue % specgram button off
            set(HANDLES.sndcontrol,'Visible','off') % turn off sound control
            set(HANDLES.delimit.but,'Visible','off') % turn off delimit switch
            if ~spvalue % spectra button off
                set(HANDLES.allcontrol,'Visible','off') % turn off all XWAV control
                set(HANDLES.displaycontrol,'Visible','on') %turn on top row buttons
            end
        end
    end
    if MultiChValue
        set(HANDLES.ch.txt, 'Visible', 'off')
        set(HANDLES.ch.pop, 'Visible', 'off')
    end
    plot_triton
elseif strcmp(action,'spectra')
    if MultiChValue
        set(HANDLES.ch.txt, 'Visible', 'off')
        set(HANDLES.ch.pop, 'Visible', 'off')
        set(HANDLES.display.timeseries, 'Value', 0)
        set(HANDLES.display.specgram, 'Value', 0)
        control('ampoff')
        set(HANDLES.sgequal,'Visible','off')
    end
    if spvalue
        set(HANDLES.spectracontrol,'Visible','on')
        if PARAMS.nch > 1
            set(HANDLES.mc.on, 'Visible', 'on')
            %         set(HANDLES,'Visible', 'on')
        end
    elseif ~spvalue
        %         set(HANDLES.tfradios,'Visible','off')
        set(HANDLES.fax.log, 'Visible', 'off')
        set(HANDLES.fax.linear, 'Visible', 'off')
        if ~tsvalue && ~sgvalue
            set(HANDLES.mc.on, 'Visible', 'off')
            %         set(HANDLES.mc.off,'Visible', 'off')
        end
        if ~sgvalue
            control('ampoff')
            control('freqoff')
            set(HANDLES.tfradios,'Visible','off')
            if ~tsvalue
                set(HANDLES.allcontrol,'Visible','off')
                set(HANDLES.displaycontrol,'Visible','on')
            end
        end
    end
    if MultiChValue
        set(HANDLES.ch.txt, 'Visible', 'off')
        set(HANDLES.ch.pop, 'Visible', 'off')
    end
    plot_triton
elseif strcmp(action,'specgram')
    if MultiChValue
        set(HANDLES.display.spectra, 'Value', 0)
        set(HANDLES.tfradios,'Visible','on')
        set(HANDLES.display.timeseries, 'Value', 0)
    end
    if sgvalue
        set(HANDLES.specgramcontrol,'Visible','on')
        if PARAMS.nch > 1
            set(HANDLES.mc.on, 'Visible', 'on')
            %         set(HANDLES.mc.off,'Visible', 'on')
        end
    elseif ~sgvalue
        control('ampoff')
        set(HANDLES.sgequal,'Visible','off')
        if ~tsvalue  && ~spvalue
            set(HANDLES.mc.on, 'Visible', 'off')
            %         set(HANDLES.mc.off,'Visible', 'off')
        end
        if ~tsvalue
            set(HANDLES.sndcontrol,'Visible','off')
            set(HANDLES.delimit.but,'Visible','off') % turn off delimit switch
        end
        if ~spvalue
            control('freqoff')
            set(HANDLES.tfradios,'Visible','off')
            if ~tsvalue
                set(HANDLES.allcontrol,'Visible','off')
                set(HANDLES.displaycontrol,'Visible','on')
            end
        end
    end
    
    if MultiChValue
        set(HANDLES.fax.linear, 'Visible', 'off')
        set(HANDLES.fax.log, 'Visible', 'off')
        set(HANDLES.ch.txt, 'Visible', 'off')
        set(HANDLES.ch.pop, 'Visible', 'off')
    end
    if ~spvalue
        set(HANDLES.fax.log, 'Visible', 'off')
        set(HANDLES.fax.linear, 'Visible', 'off')
    end
    plot_triton
    
elseif strcmp(action,'ltsa')
    if savalue
        set(HANDLES.ltsa.allcontrol,'Visible','on')
    elseif ~savalue
        set(HANDLES.ltsa.allcontrol,'Visible','off')
    end
    plot_triton
    if get(HANDLES.mc.lock, 'Value')
        fig_hand = get(HANDLES.plot1,'Parent');
        all_hands = findobj(fig_hand, 'type', 'axes', 'tag', '');
        if savalue
            % set the value of the ltsa handle to 0 so that it's not linked
            % with the zoom in
            all_hands (PARAMS.ch + savalue) = 0;
        end
        linkaxes(all_hands,'x');
    end
end

if m == 0
    set(HANDLES.allcontrol,'Visible','off')
    set(HANDLES.ltsa.allcontrol,'Visible','off')
    % gotta keep the display control on to reactivate the plots without
    % re-opening the files
    if ~isempty(PARAMS.infile)
        if ~isempty(PARAMS.ltsa.infile)
            set(HANDLES.displaycontrol,'Visible','on')
            set(HANDLES.display.ltsa,'Visible','on')
        else
            set(HANDLES.displaycontrol,'Visible','on')
        end
    else
        if ~isempty(PARAMS.ltsa.infile)
            set(HANDLES.display.ltsa,'Visible','on')
        end
    end
end