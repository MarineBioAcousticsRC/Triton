function control_log(varargin)
% control_log(action) or control_log(gui callback args, action)
% Callback for handling log events
% May be called directly or as a GUI callback.
% GUI callbacks have the signature:
%   hObject, eventdata, guidata
% where guidata is expected to be the action argument.
%
% action indicates is being performed, such as the adhoc toggle button
% which alternates between logging on and off effort detections.

if length(varargin) > 2
    hObject = varargin{1};
    eventdata = varargin{2};
end
action = varargin{end};

global handles PARAMS TREE HANDLES

switch action
    case 'adhoc'
        % switch between on and off effort 
        
        
        
        % if the button was already pushed revert color back to gray
        switch PARAMS.log.mode
            case 'OffEffort'
                % Was ad-hoc, moving back on effort
                PARAMS.log.mode= 'OnEffort';
                EffortStr = 'On Effort -> Off Effort';
                BgColor = [.80 .80 .80]; % default gray
            case 'OnEffort'
                % Move to off effort logging
                PARAMS.log.mode = 'OffEffort';
                EffortStr = 'Off Effort -> On Effort';
                BgColor = [.9, .4, .6]; % orchid - make sure user remembers
        end
        
        mkChart
        set(handles.adhoc, 'String', EffortStr)
        set(handles.logcallgui, 'color',BgColor)
        control_log('display_lastentry');  % Set last entry appropriately
    
    case 'deployment_start'
        deployment = handles.deploy.disp.Value;
        if isnumeric(deployment)
            values = handles.deploy.disp.String;
            deployment = values(deployment);
        end
        
    case 'display_lastentry'
        % Update the previous entry for this effort type
        switch PARAMS.log.mode
            case 'OnEffort', LastEntryType = 'on effort';
            case 'OffEffort', LastEntryType = 'off effort';
        end
        
        currentRow = log_lastRow(handles.(PARAMS.log.mode).Sheet);
        if currentRow > 1
            pickStr = log_entries(handles.(PARAMS.log.mode), currentRow, true);
            set(handles.deletelog, 'Enable', 'on', ...
                'String', sprintf('Delete last %s', LastEntryType));
        else
            pickStr = 'No previous entry';
            set(handles.deletelog, 'Enable', 'off', ...
                'String', sprintf('%s', LastEntryType));
        end
        set(handles.previouspicks, 'String', pickStr);
        
    case 'save_effort'
        
        
        % Where should effort be saved?
        [effortfile, effortpath] = uiputfile('.xls', 'Save Effort template to');
        if isnumeric(effortfile)
            return % user cancelled
        end
        
        % Copy the effort template to the location where the user
        % would like to save the effort.
        template = getEffortTemplate();  % Filename for effort template
        saveto = fullfile(effortpath, effortfile);
        copyfile(template, saveto, 'f');

        % Write out the effort
        writeEffort(TREE.rootNode, saveto);
        
    case 'load_effort'
        [logfilename, logfilepath]=uigetfile('*.xls', ...
            'select a spreadsheet');
        
        if isnumeric(logfilename)
            return
        else
            read_effort(fullfile(logfilepath, logfilename))
            set(TREE.tree, 'visible', 0)
            pause(0.0001)
            set(TREE.tree, 'visible', 1)
        end
        
    case 'species'
        value = get(handles.species.pulldown, 'value');
        species = [TREE.speciesR{value}, filesep];
        [TREE.callR,TREE.callW] = species_ordering(species, 2, 1);
        
        % build list of parameters for calls associated with this
        % species
        callAttr = struct('call', TREE.callR);
        % 
        callRange = TREE.position+[1:length(callAttr)];
        pidx = 1;
        for idx = callRange  % for each call
            % Find parameters for this call
            paramsidx =  ~cellfun(@isempty, TREE.dFreq(idx, :));
            callAttr(pidx).params = TREE.dFreq(idx, paramsidx);
            callAttr(pidx).values = NaN * zeros(length(callAttr(pidx).params),1);
            % Store the time and frequency when the user picks a parameter
            % In most cases, the frequency will be copied to the values
            % array, but this let us easily store time-frequency pairs
            % via picking.  Note that these are not displayed.
            callAttr(pidx).timefreq = NaN * zeros(length(callAttr(pidx).params),2);            
            pidx = pidx + 1;
        end

        % Save the attributes associated with the calls for this species
        set(hObject, 'UserData', callAttr);
        % Set up the call checkboxes and any needed parameters
        init_callcheckboxes(callAttr);

        
    case 'group'
        value = get(handles.group.pulldown, 'value');
        group = [TREE.groupR{value}, filesep];
        [TREE.speciesR,TREE.speciesW] = species_ordering(group);
        set(handles.species.pulldown,'string', TREE.speciesR)
        
        set(handles.species.pulldown, 'value', 1)
        control_log(handles.species.pulldown, [], 'species');
        
    case 'log'
        logcallxls
        
    case 'savejpg'
        color = get(handles.savejpegbutton, 'BackgroundColor');
        % save current button label in case we fail
        button_label = get(handles.savejpegbutton, 'String');
        set(handles.savejpegbutton, 'BackgroundColor', color*.9);
        if isempty(handles.log.image)
            handles.log.image = fullfile(handles.log.imagedir, 'temp.jpg');
            try
                saveas(HANDLES.fig.main, handles.log.image);
                button_label = 'Clear Image';
            catch
                handles.log.image = [];
                errordlg('Unable to save plot window');
            end
        else
            button_label = 'Save Image';
            handles.log.image = [];
        end
        set(handles.savejpegbutton, 'BackgroundColor', color, ...
            'String', button_label);

        
    case 'mkXWAV'
        color = get(handles.savexwavbutton, 'BackgroundColor');
        % save current button label in case we fail
        button_label = get(handles.savexwavbutton, 'String');
        set(handles.savexwavbutton, 'BackgroundColor', color*.9);
        if isempty(handles.log.audio)
            try
                fname = fullfile(handles.log.audiodir, 'temp.x.wav');
                savexwav(fname);
                handles.log.audio = fname;
                button_label = 'Clear Audio';
            catch e
                button_label = 'Save Audio';
                badfield(handles.savexwavbutton, e.message, .75);
            end
        else
            button_label = 'Save Audio';
            handles.log.audio = [];
        end

        set(handles.savexwavbutton, 'BackgroundColor', color, ...
            'String', button_label);
                
    case 'set_metadata'
        
        % Retrieve the set of ids associated with deployments
        deployment_id = log_getdeploymentids();
        % Verify user has filled in requested fields before proceeding
        fields = {'deploy', 'user', 'effort_start'};
        WorksheetNames = { 'DeploymentId', 'User ID', 'Effort Start'};
        values = cell(length(fields),1);
        bad = zeros(1, length(fields));
        for fidx = 1:length(fields)
            current_h = handles.(fields{fidx}).disp;
            switch current_h.Style
                case 'popupmenu'
                    % Retrieve currently selected value
                    selection = current_h.Value
                    values{fidx} = current_h.String{selection};
                case 'edit'
                    values{fidx} = current_h.String;
            end
            
            bad(fidx) = isempty(values{fidx});
            % Additional checking
            switch fields{fidx}
                case 'user'
                    if isempty(values{fidx})
                        bad(fidx) = true;  % no empty UserId
                    end
                case 'effort_start'
                    % Verify date format
                    try
                        values{fidx} = datenum(values{fidx});
                        values{fidx} = datestr(values{fidx}, 31);
                    catch excep
                        bad(fidx) = true;
                    end
                case 'deploy'
                    % Verify correct deployment if possible
                    if ~ isempty(deployment_id)
                        matches = find(strcmpi(values{fidx}, deployment_id));
                        if length(matches) == 1
                            % Use canonical value from database in case
                            % user had incorrect case
                            values{fidx} = deployment_id(matches);
                        else
                            response = questdlg(join([
                                "Proceed?  You will not be allowed to" ...
                                "submit this log until a deployment" ...
                                "with this Id is present, or the Id", ...
                                "is changed."], " "), ...
                                "No such deployment in the Tethys database", ...
                                "Yes", "Let me fix it", "Let me fix it");
                            switch response
                                case "Let me fix it"
                                    bad(fidx) = true;
                            end
                        end
                    end
            end
        end
        
        if sum(bad) > 0
            red = [1 0 0];
            % one or more fields not filled in, flash the bad fields
            oldcolors = size(length(bad), length(red));
            for b = find(bad)
                oldcolor(b,:) = get(handles.(fields{b}).disp, 'BackgroundColor');
                set(handles.(fields{b}).disp, 'BackgroundColor', red);
            end
            error('Deployment must be numeric and Effort must be date/time format!')
            pause(.5);
            for b = find(bad)
                set(handles.(fields{b}).disp, 'BackgroundColor', oldcolor(b,:));
            end
            return  % bail out
        end
        
        % Save metadata
        1;
        % Turn off effort start callback
        PARAMS.log.pick = [];  
        pickxyz(true);  % set cursor appropriately
        
        % Passed initial integrity checks, request effort
        set(handles.log.effort, 'Visible', 'off');  % Hide metadata
        set(handles.done, 'Visible', 'off');
        set(handles.effortPane, 'Visible', 'on');
        log_open(WorksheetNames, values);
        set(TREE.tree, 'Visible', 1); % overlay effort tree

        
        % New log, make sure that on/off effort detections are empty
        for f = {'OnEffort', 'OffEffort'}
            f = f{1};
            RowsN = handles.(f).Sheet.UsedRange.Rows.Count;
            % Clear all used rows after headers
            if RowsN > 1
                Range = handles.(f).Sheet.Range(sprintf('2:%d', RowsN));
                Range.Clear();  % clear out any data
                Range.EntireRow.Delete();  % remove rows
            end
        end
        
    case {'set_effort', 'append'}
        if strcmp(action, 'set_effort')
            %get granularity value
            temp=get(handles.granularity,{'String','Value'});
            TREE.gran = temp{1}{temp{2}};
            %see if binned time was seleted and if so check if the time is
            %divisible by 24h (1440m)
            if strcmp(TREE.gran,'binned')
                badField = 0;
                %Convert text to string and put in global varible
                [TREE.binTime,status] = str2num(get(handles.binTime,'String'));
                if status == 0
                    msg = 'Binned time not a number';
                    badField = 1;%not a number
                end
                remaining = mod(24*60, TREE.binTime);
                if remaining ~= 0
                   msg = sprintf('Bin time must divide evenly into 24 h; remaining = %d m', remaining);
                   badField = 1; %not divisible by 24 hours
                end
                %if the time is bad, flash red and exit function
                if badField == 1
                    oldColor = get(handles.binTime, 'BackgroundColor');
                    set(handles.binTime, 'BackgroundColor',[1 0 0]);%red
                    pause(.5);
                    set(handles.binTime, 'BackgroundColor', oldColor);
                    disp_msg(msg);
                    return;
                end
            end
            %passed checks, proceed to write effort sheet
            writeEffort(TREE.rootNode, handles.Workbook);
            % No need to open the log, we already did so.
        else
            read_effort(handles.logfile);
            log_open();
        end
        
        % Hide the effortPane, bin controls and tree
        set(handles.effortPane, 'Visible', 'off');
        set(handles.binLabel, 'Visible', 'off');
        set(handles.binTime, 'Visible', 'off')
        set(TREE.tree, 'Visible', 0); 
        
        % enable logging controls
        set(handles.log.control, 'Visible', 'on');
        mkChart;  % Populate initial Group & Species pulldowns
        PARAMS.log.pick = 'timeXfreq';
        makeEffortStruct; %save whats on effort
        pickxyz(true);  % set up selection cursor
        
        % Show last selection (if any)
        control_log('display_lastentry');

    case 'delete_log'
        % Remove the last row if an entry exists.
        currentRow = log_lastRow(handles.(PARAMS.log.mode).Sheet);
        if currentRow > 1
            Range = handles.(PARAMS.log.mode).Sheet.Range(...
                sprintf('%d:%d', currentRow, currentRow));
            Range.Clear();  % clear out any data
            Range.EntireRow.Delete();  % remove row
            control_log('display_lastentry');
        end
        
    case 'set_meta_end'
        endeffort = get(handles.effort_end.disp, 'String');
        try
            enddate = datenum(endeffort);  % convert to serial date
        catch
            badfield(handles.effort_end.disp, 'Bad end time', .5);
            return
        end
        if isempty(enddate)
            badfield(handles.effort_end.disp, 'Specify End time', .5);
            return
        end

        if ~isempty(handles.log.lastDate) && enddate < handles.log.lastDate
            badfield(handles.effort_end.disp, 'Before last detection', .5);
            return
        end
        if ~ isempty(handles.log.endDate) && handles.log.endDate > enddate
            choice = questdlg(sprintf('Selected end of effort %s < existing end %s', ...
                datestr(enddate, 'yyyy/mm/dd HH:MM:SS'), ...
                datestr(handles.log.endDate, 'yyyy/mm/dd HH:MM:SS')), ...
                'Effort will be reduced', ...
                'Proceed', 'Choose new date', 'Choose new date');
            if strcmp(choice, 'Choose new date');
                return
            end
        end
        log_close(enddate);

        
    case 'set_parameter'
        % User has pressed one of the set parameter buttons.  Copy
        % value from the current pick.

        % Retrieve the last selected time X frequency
        tf = get(handles.timefreq, 'UserData');
        if isempty(tf)
            % No selections yet
            return
        end
        
        % Retrieve the call attributes
        callAttr = get(handles.species.pulldown, 'UserData');
        
        % Determine which call and parameter is to be set.
        map = get(hObject, 'UserData');
        callidx = map(1);
        paramidx = map(2);
        buttonidx = map(3);
        
        % if user pressed a parameter button, copy value in from
        % last pick
        change = false;
        if find(handles.freq == hObject) 
            if ~ isempty(tf{1}.freq)
                % Currently only storing frequencies via button mechanism
                callAttr(callidx).values(paramidx) = tf{1}.freq;
                callAttr(callidx).timefreq(paramidx, :) = ...
                    [tf{1}.time tf{1}.freq];
                set(handles.species.pulldown, 'UserData', callAttr);
                set(handles.freqdisplay(buttonidx), ...
                    'String', num2str(tf{1}.freq));
                change = true;
            end
        else
            % User entered value via text box.  Save it
            value = str2num(get(hObject, 'String'));
            if isempty(value)
                % Bad value, restore previous one
                set(gcbo, 'String', ...
                    num2str(callAttr(callidx).values(paramidx)));
            else
                callAttr(callidx).values(paramidx) = value;
                change = true;
            end
        end
        % Store call attributes if they have changed
        if change
            set(handles.species.pulldown, 'UserData', callAttr);
        end
        
    case {'pickstart', 'pickend'}
        field = sprintf('%sdisplay', action);
        posn = strcmp(action, {'pickstart', 'pickend'});
        time_from_pick(handles.timefreq(posn), handles.(field));
        
    case 'pickboth'
        field = {'pickstartdisplay', 'pickenddisplay'};
        for idx=1:2
            tmp = time_from_pick(handles.timefreq(idx), handles.(field{idx}));
            if isempty(tmp)
                return
            else
                tf(idx) = tmp;
            end
        end

        % Populate some parameters automatically
        % check is a cell array where each row contains:
        %   predicate (only run check if true)
        %   statistic - statistic of selection
        %   regular expression - must be contained in call parameter
        freqs = [tf.freq];
        times = [tf.time];
        s_per_day = 24*3600;
        check = cell(0,3);
        if length(freqs) >= 1
            check = vertcat(check, ...
            {length(freqs) > 1, min(tf.freq), '^Min(.*Hz.*)?$';
            length(freqs) > 1, max(tf.freq), '^Max(.*Hz.*)?$';
            length(freqs) > 1, freqs(1), '^(Begin|Start)(.*Hz.*)?$';
            length(freqs) > 1, freqs(end), '^(End|Stop)(.*Hz.*)?$'});
        end
        if length(times)> 1
            check = vertcat(check, ...
                {length(times) > 1, diff(times)*s_per_day, '^Duration_s.*$'});
        end
        
        callAttr = get(handles.species.pulldown, 'UserData');
        selected = get(handles.calltype, 'Value');
        if iscell(selected)
            selected = cell2mat(selected);
        end
        changed = false;
        for cidx=1:length(selected)
            if selected(cidx)
                found = false;
                
                for chkidx = 1:size(check, 1)
                    if ~ check{chkidx, 1}
                        continue;  % failed predicate test
                    end
                    % See if parameter listed
                    idx = find(~cellfun(@isempty, ...
                        regexp(callAttr(cidx).params, ...
                        check{chkidx, 3}, 'ignorecase')), 1, 'first');
                    if ~ isempty(idx)
                        changed = true;
                        callAttr(cidx).values(idx)= check{chkidx, 2};
                        % Update the parameters text box if it is
                        % currently displayed
                        displayCallParam(cidx, idx, check{chkidx, 2});
                    end
                end
            end
        end
        if changed
            set(handles.species.pulldown, 'UserData', callAttr);
        end
    case 'set_gran'
        %binned is the third value of the pulldown
        if get(handles.granularity, 'Value') == 3
            set(handles.binTime,'Visible', 'on');
            set(handles.binLabel,'Visible', 'on');
        else
            set(handles.binTime,'Visible', 'off');
            set(handles.binLabel,'Visible', 'off'); 
        end
        
    case 'workbook_visibility_toggle'
        if isfield(handles, 'Server')
            handles.Server.visible = ~handles.Server.visible;
        else
            str = get(HANDLES.fig.ctrl, 'Name');
            set(HANDLES.fig.ctrl, 'Name', 'No log currently active');
            pause(1)
            set(HANDLES.fig.ctrl, 'Name', str);
        end            
end

    function displayed = displayCallParam(cidx, pidx, value)
        % displayed = displayCallParam(cidx, pidx, value)
        % Look through the list of displayed call parameters to
        % see if the cidx'th call has the pidx'th parameter displayed.
        % If it does, set the value.
        
        displayed = false;  % Assume not displayed until we find it
        idx = 1;
        while ~displayed && idx <= length(handles.freq)
            % Each parameter box has the call number and parameter
            % stored in the user data
            map = get(handles.freq(idx), 'UserData');
            if map(1) == cidx && map(2) == pidx
                % We found the right one, update it and bail out of loop
                displayed = true;
                set(handles.freqdisplay(idx), 'String', num2str(value));
            else
                idx = idx + 1;  % check the next one
            end
        end
    end
       
        
    function tf = time_from_pick(pickH, timeH)
        % tf = time_from_pick(pickH, timeH)
        % Given a handle to a pick field, copy the information
        % associated with the pick to a time display and format
        % the time string.
        tf = get(pickH, 'UserData');
        if isstruct(tf) && isfield(tf, 'time')
            timestr = datestr(tf(1).time, 'YYYY-mm-DD HH:MM:SS.FFF');
            set(timeH, 'String', timestr, 'UserData', tf);
        end
    end
        

    function init_callcheckboxes(callAttribs)
        handles.prev = 0;
        calls = {callAttribs.call};
        %handles.freqDisp = cell(length(calls), PARAMS.numfreq);
        
        % Determine layout for checkboxes
        c = 2;
        if length(calls) > 4
            r = ceil(length(calls)/c);
        else
            r = 3;
        end
        h = 1/r;
        w = 1/c;
        sep = w/10;
        bgColor = [0.8 0.3 0.8];
        for ci = 1:c
            x(:,ci) = ((ci-1)/c) .* ones(r,1);
            y(:,ci) = h .* [r-1:-1:0]';
        end
        
        k = 1;
        callLength = length(calls);
        for cx = 1 : c
            for cy = 1:r
            callbtnpos{k} = [x(1,cx)+sep, y(cy,1), w-sep, h];
            k = k+1;
            end
        end
        
        % Remove any existing buttons
        delete(get(handles.speciesbuttons,'children'));
        handles.calltype = [];
        
        for i = 1:length(callAttribs)
            handles.calltype(i) = uicontrol('style','checkbox',...
                'String',calls{i},...
                'Units', 'normalized',...
                'pos',callbtnpos{i},...
                'backgroundcolor', bgColor,...
                'Parent',handles.speciesbuttons,...
                'Callback', {@call_checkbox, i});
        end
        if length(callAttribs) == 1
            set(handles.calltype(1), 'Value', 1);
        end
        set(handles.speciesbuttons, 'selectedObject', [])
        
        % Initialize parameters by invoking checkbox callback
        % with fake values
        call_checkbox([], [], []);
    end

    function call_checkbox(objectH, eventdata, call_idx)
    % call_checkbox = (objectH, eventdata, call_idx)
    % Callback for select/deselect a call type
    
    % Populate parameters for selected calls
    
    paramsN = length(handles.freq);  % Maximum # parameters
    
    % Retrieve information about calls and possible parameters
    callAttr = get(handles.species.pulldown, 'UserData');
    done = false;
    % Populate parameters up to paramsN then stop
    cidx = 1;  % call index
    used = 0;  % # parameters used
    while cidx <= length(callAttr) && used < paramsN;
        if get(handles.calltype(cidx), 'Value')
            % call has been selected, populate attributes up to
            % the last available slot
            for aidx = 1:min(length(callAttr(cidx).params), ...
                    paramsN - used)
                used = used + 1;
                % Attribute map
                % Note current call, current attribute, and position 
                % in the list of parameters.  This will let us find
                % the call, attribute, and button/edit box index from
                % a callback.
                attributeMap = [cidx, aidx, used];
                % Set label and value & attribute map
                set(handles.freq(used), 'String', ...
                    sprintf('%d %s %s', used, ...
                        callAttr(cidx).params{aidx}, callAttr(cidx).call), ...
                    'Visible', 'on', 'UserData', attributeMap);
                % Store the attributeMap and set the current value of the
                % call attribute
                set(handles.freqdisplay(used), 'String', ...
                    num2str(callAttr(cidx).values(aidx)), ...
                    'Visible', 'on', 'UserData', attributeMap);
            end
        end
        cidx = cidx+1;
    end
    
    % Make remaining parameters invisible
    for rest = used+1:paramsN
        set(handles.freq(rest), 'Visible', 'off');
        set(handles.freqdisplay(rest), 'Visible', 'off');
    end
    
    end  % end function

    function string = find_subtype(calltype)
        string = [];
        for i = 1:length(calltype)
             call = [calltype{i}, filesep];
             [subtypeR,subtypeW] = species_ordering(call);
             if isempty(subtypeR) || strcmp(subtypeR(1),calltype(1))                 
                 subtypeR = [];
              end
             subtypeR = find_subtype(subtypeR);
             if isempty(subtypeR)
                 string{length(string)+1} = calltype{i};
             else
                 for x = 1:length(subtypeR)
                     string{length(string)+1} = [call,subtypeR{x}];
                 end
             end
        end
    end

    function mkChart
        [TREE.textR,TREE.textW, TREE.orderR, TREE.dFreq] = disp_sect;
        if ~isempty(TREE.textR)
            [TREE.groupR,TREE.groupW] = species_ordering('root');
            %set the group string to the group
            
            set(handles.group.pulldown, 'value', 1)
            set(handles.group.pulldown,'string', TREE.groupR)
            
            [TREE.speciesR,TREE.speciesW] = species_ordering([TREE.groupR{1}, filesep],1,1);
            
            set(handles.species.pulldown, 'value', 1)
            set(handles.species.pulldown,'string', TREE.speciesR)
            
            
            [TREE.callR,TREE.callW] = species_ordering([TREE.speciesR{1}, filesep],2,1);
            control_log(handles.species.pulldown, [], 'species');

        end
    end
    %need the effort struct to help with hotkeys
    function makeEffortStruct
        TREE.effort = [];
        y = 1;
        groupIdx = 1;
        speciesIdx = 1;
        theMax = length(TREE.textR);
        while y < length(TREE.textR)
            nextGroup = 0;
            if y <= theMax && ~strcmp(TREE.textR(y,1), '')%there is a groupname
                group.name = TREE.textR(y,1);
                y = y+1; %go yo next line down
                
                species = [];
                while ~nextGroup && y <= theMax
                    species.name = TREE.textR(y,2);
                    y = y+1;
                    x = 1;
                    species.calls = [];
                    while y <= theMax && ~strcmp(TREE.textR(y,3), '')
                        species.calls{x} = TREE.textR{y,3};
                        y = y + 1;
                        x = x+1;
                    end
                    group.species{speciesIdx} = species;
                    speciesIdx = speciesIdx + 1;
                    if y <= theMax && ~strcmp(TREE.textR(y,1), '')
                        nextGroup = 1;
                        speciesIdx = 1;
                    end
                end
                TREE.effort{groupIdx} = group;
                group = [];
                groupIdx = groupIdx + 1;
            end
        end
    end
end
