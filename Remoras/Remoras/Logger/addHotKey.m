function addHotKey(varargin)
%draws the gui for adding hotkeys and then adds them to the xml spreadsheet
%keyMap.xml
global handles PARAMS TREE keymap group species %need a few global varibles for nested functions to have access

if ~isfield(PARAMS.log, 'mode')
    disp_msg('The logger must be open');
    return;
end

buildWindow%build the gui, put below for clarity.
oldKey = [];

%populate the right fields with exiting keys values. For logger keys
%that means getting the right group, species and call
    function existingsKeys(varargin)
        keyIdx = get(keymap.existingKeys, 'value') - 1; %-1 for the add
        %user selected add new key
        if(keyIdx == 0)
            set(keymap.defCheck, 'Value', 1);
            set(keymap.key, 'String', '');
            oldKey = [];
            set(keymap.loggerItems, 'Visible', 'on')
            return; %trying to add a new key
        end
        
        %getting the right index from a list of strings and mapping them to
        %four seperate lists is tricky. Sets the key picked to the value
        %oldKey so that it may be overwriten in the save. Some math is
        %involved but the final idx value of the right modifier is stored
        %in oldKey.idx.
        defIdx =  length(PARAMS.keypress.DefaultKeys.Key);
        offset = defIdx;
        ctrlIdx = -1;
        altIdx = -1;
        shiftIdx = -1;
        if isstruct(PARAMS.keypress.CtrlKeys)
            ctrlIdx = offset + length(PARAMS.keypress.CtrlKeys.Key);
            offset = ctrlIdx;
        end
        if isstruct(PARAMS.keypress.AltKeys)
            altIdx = offset + length(PARAMS.keypress.AltKeys.Key);
            offset = altIdx;
        end
        if isstruct(PARAMS.keypress.ShiftKeys)
            shiftIdx = offset + length(PARAMS.keypress.ShiftKeys.Key);
        end
        
        if keyIdx <= defIdx
            key = PARAMS.keypress.DefaultKeys.Key(keyIdx);
            set(keymap.defCheck, 'Value', 1);
            oldKey = key;
            oldKey.modifier = 'DefaultKeys';
            offset = keyIdx;
        elseif keyIdx <= ctrlIdx %will only enter if ctrlIdx was set
            offset = length(PARAMS.keypress.CtrlKeys.Key) - (ctrlIdx - keyIdx);
            key = PARAMS.keypress.CtrlKeys.Key(offset);
            oldKey = key;
            oldKey.modifier = 'CtrlKeys';
            set(keymap.ctrlCheck, 'Value', 1);
        elseif keyIdx <= altIdx %will only enter if altIdx was set
            offset = length(PARAMS.keypress.AltKeys.Key) - (altIdx - keyIdx);
            key = PARAMS.keypress.AltKeys.Key(offset);
            oldKey = key;
            oldKey.modifier = 'AltKeys';
            set(keymap.altCheck, 'Value', 1);
        elseif keyIdx <= shiftIdx %will only enter if shift idx was set
            offset = length(PARAMS.keypress.ShiftKeys.Key) - (shiftIdx - keyIdx);
            key = PARAMS.keypress.ShiftKeys.Key(offset);
            oldKey = key;
            oldKey.modifier = 'ShiftKeys';
            set(keymap.shiftCheck, 'Value', 1);
        end
        oldKey.idx = offset;
        set(keymap.key, 'String', key.name);
        
        %determine the right group, species, and call to populate the
        %window with.
        if strcmp(key.param, '~isempty(handles)') & strfind(key.fn, 'hotkeyHelp') %do special stuff for logging keys
            reg =  '\([^]*\)';
            [start, e] = regexp(key.fn, reg);
            functionCall = key.fn(start+1: e-1);
            reg = '\x2C';
            start = regexp(functionCall, reg);
            groupS = eval(functionCall(1:start(1)-1));
            speciesS = eval(functionCall(start(1)+1:start(2)-1));
            groupIdx = find(ismember(get(group.pulldown, 'string'), groupS));
            set(group.pulldown, 'Value', groupIdx)
            populateGroup;
            speciesIdx = find(ismember(get(species.pulldown, 'String'), speciesS));
            set(species.pulldown, 'Value', speciesIdx)
            populateSpecies;
            reg = '\{[^]*\}';
            [~,~,~, calls] = regexp(key.fn, reg);
            calls = eval(calls{:});
            callNames = get(species.calltype, 'string');
            callIdxs = find(ismember(callNames,calls));
            for x = 1:length(callIdxs)
                set(species.calltype(callIdxs(x)), 'value', 1);
            end
            set(keymap.loggerItems, 'Visible', 'on')
        else %just modifying an existing key
            set(keymap.loggerItems, 'Visible', 'off')
        end
        
    end


    function saveKeystroke(~,~,~)
        key =  get(keymap.key, 'String');
        %either entered to long or to short of a key. TODO make it handle
        %arrows better, will need to be able to input "leftarrow" etc
        if isempty(key) || length(key) > 1
            %flash red
            oldColor = get(keymap.key, 'BackgroundColor');
            set(keymap.key, 'BackgroundColor', [1 0 0]);
            pause(.5);
            set(keymap.key, 'BackgroundColor', oldColor);
            disp_msg('Key must be exactly one character');
            return;
        end
        %if the loggerItems are visible, then the user is modifieing an
        %existing key or adding a new key and we will need the new calls
        %saved
        if strcmp(get(keymap.loggerItems, 'Visible'), 'on')  %will need all of the values since this is a logger call
            group.selected = TREE.groupR(get(group.pulldown, 'Value'));
            group.selected = strrep(group.selected, '''', ''''''); %hot key does not like quotes
            [len, ~] = size(get(species.calltype, 'String'));
            if len == 1
                callIdxs = 1;
            else
                callIdxs = find(cell2mat(get(species.calltype, 'Value')), '1');
            end
            species.selected = TREE.speciesR(get(species.pulldown, 'Value'));
            species.selected = strrep(species.selected, '''', ''''''); %hot key does not like quotes
            calls = '';
            for x = 1:length(callIdxs)
                calls = [calls, ' ''', get(species.calltype(callIdxs(x)), 'String') ''''];
            end
            calls = [ '{' calls '}'];
            calls = char(calls);
        end
        
        %Get the modifier
        modifier =  get(get(keymap.radio, 'SelectedObject'),'Tag');
        
        %is this a new field or an old one?
        if isfield(PARAMS.keypress.(modifier), 'Key')
            idx = length(PARAMS.keypress.(modifier).Key) + 1;
        else
            idx = 1; %no key field yet in array
        end
        
        if isempty(oldKey)%new key added, just add to the end
            addLoggerCalls(modifier, idx, key, calls);
        elseif ~isempty(oldKey)%editing an old key
            if strcmp(oldKey.modifier, modifier)%keeping the same modifier key
                if strcmp(get(keymap.loggerItems, 'Visible'), 'on')%editing a logger key
                    addLoggerCalls(oldKey.modifier, oldKey.idx, key, calls);
                else%changing keys for none logger
                    editNoneLogger(oldKey, oldKey.modifier, idx, key)
                end
            else %changing the modifier key
                if strcmp(get(keymap.loggerItems, 'Visible'), 'on')%editing a logger key
                    removeKey(oldKey.modifier, oldKey.idx);
                    addLoggerCalls(modifier, idx, key, calls);
                else%changing keys for none logger
                    removeKey(oldKey.modifier, oldKey.idx);
                    editNoneLogger(oldKey, modifier, idx, key)
                end
            end
        end
        
        write;
        closeWindow;
    end
%add a logger key
    function addLoggerCalls(modifier, idx, keyName, calls)
        PARAMS.keypress.(modifier).Key(idx).name = keyName;
        PARAMS.keypress.(modifier).Key(idx).fn = ['hotkeyHelp(''' group.selected{1} ''',''' species.selected{1} ''',' calls ')'];
        PARAMS.keypress.(modifier).Key(idx).param = '~isempty(handles)';
        PARAMS.keypress.(modifier).Key(idx).description = ['Switch to ' species.selected{1}, ' with calls ' calls];
        
    end
%edit a none logger key
    function editNoneLogger(oldKey, modifier, idx, keyName)
        PARAMS.keypress.(modifier).Key(idx).name = keyName;
        PARAMS.keypress.(modifier).Key(idx).fn = oldKey.fn;%function stays the same
        PARAMS.keypress.(modifier).Key(idx).param = oldKey.param;
        PARAMS.keypress.(modifier).Key(idx).description = oldKey.description;
    end
%remove an existing key.
    function removeKey(modifier, idx)
        lastIdx = length(PARAMS.keypress.(modifier).Key);
        if lastIdx == 1 %only one key so set modifier to empty
            PARAMS.keypress.(modifier) = [];
            return;
        elseif lastIdx == idx
            PARAMS.keypress.(modifier).Key(lastIdx) = [];
        else
            PARAMS.keypress.(modifier).Key(idx) = PARAMS.keypress.(modifier).Key(lastIdx);
            PARAMS.keypress.(modifier).Key(lastIdx) = [];
        end
    end
    function removeKeystroke(~,~,~)
        removeKey(oldKey.modifier, oldKey.idx);
        write;
        closeWindow;
    end

    function write
        pref.StructItem = false;
        pref.CellItem = false;
        saveLoc = which('keymap.xml');
        xml_write(saveLoc, PARAMS.keypress,'Keymap', pref );
    end

    function closeWindow(~,~,~)
        control_log(handles.group.pulldown, [], 'group')
        close();
    end

%ripped and modified from logger
    function mkChart
        [TREE.textR,TREE.textW, TREE.orderR, TREE.dFreq] = disp_sect;
        if ~isempty(TREE.textR)
            [TREE.groupR,TREE.groupW] = species_ordering('root');
            %set the group string to the group
            
            set(group.pulldown, 'value', 1)
            set(group.pulldown,'string', TREE.groupR)
            
            [TREE.speciesR,TREE.speciesW] = species_ordering([TREE.groupR{1}, filesep],1,1);
            
            set(species.pulldown, 'value', 1)
            set(species.pulldown,'string', TREE.speciesR)
            
            
            [TREE.callR,TREE.callW] = species_ordering([TREE.speciesR{1}, filesep],2,1);
            populateSpecies;
            %control_log(handles.species.pulldown, [], 'species');
            
        end
    end

%ripped and modified from logger
    function populateGroup(~,~,~) %don't care about input arguments
        
        value = get(group.pulldown, 'value');
        group.list = [TREE.groupR{value}, filesep];
        [TREE.speciesR,TREE.speciesW] = species_ordering(group.list);
        set(species.pulldown,'string', TREE.speciesR)
        
        set(species.pulldown, 'value', 1)
        %control_log(handles.species.pulldown, [], 'species');
        populateSpecies;
    end

%ripped and modified from logger
    function populateSpecies(~,~,~) %don't care about input arguemnts
        value = get(species.pulldown, 'value');
        species.list = [TREE.speciesR{value}, filesep];
        [TREE.callR,TREE.callW] = species_ordering(species.list, 2, 1);
        
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
        set(species.pulldown, 'UserData', callAttr);
        init_callcheckboxes(callAttr);
    end

%ripped and modified from logger
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
            a(:,ci) = ((ci-1)/c) .* ones(r,1);
            b(:,ci) = h .* [r-1:-1:0]';
        end
        
        k = 1;
        callLength = length(calls);
        for cx = 1 : c
            for cy = 1:r
                callbtnpos{k} = [a(1,cx)+sep, b(cy,1), w-sep, h];
                k = k+1;
            end
        end
        % Remove any existing buttons
        delete(get(keymap.speciesbuttons,'children'));
        species.calltype = [];
        
        for i = 1:length(callAttribs)
            species.calltype(i) = uicontrol('style','checkbox',...
                'String',calls{i},...
                'Units', 'normalized',...
                'pos',callbtnpos{i},...
                'backgroundcolor', bgColor,...
                'Parent',keymap.speciesbuttons);
            %'Callback', {@call_checkbox, i});
        end
        if length(callAttribs) == 1
            set(species.calltype(1), 'Value', 1);
        end
        set(keymap.speciesbuttons, 'selectedObject', [])
        
        % Initialize parameters by invoking checkbox callback
        % with fake values
        %call_checkbox([], [], []);
    end

    function buildWindow
        % 20 rows, 4 columns, except for motion control buttons
        r = 20; % rows
        c = 5;  % columns
        h = 1/r;
        w = 1/c;
        dsepx = w *.10; % use this if you you dont want a seperation
        dsepy = h * .25; % use this if you you dont want a seperation
        %
        % make x and y locations in plot control window (relative units)
        for ci = 1:c
            x(:,ci) = ((ci-1)/c) .* ones(r,1);
            y(:,ci) = h .* [r-1:-1:0]';
        end
        
        % now only 15 columns
        for ri = 1:r
            dy = h * 0.25;
            y(ri,:) = y(ri,:) - ri*dy;
        end
        
        for ci = 1:c
            dx = w * 0.1;
            x(:,ci) = x(:,ci) + ci*dy;
        end
        
        bgColor1 = [1 1 1];  % white
        
        bgColor2 = [0.9 0.9 0]; % yellow
        bgColor3 = [.75 .875 1]; % light blue
        bgColor4 = [1.0 .60 .0]; % orange
        bgColor5 = [0.8 0.3 0.8]; % purple
        bgColor6 = [0.1 0.8 1.0]; % blue
        bgColor7 = [0.4 1.0 0.4]; % green
        bgColor8 = [0.8 0.8 0.8]; % gray
        
        keymap.window = figure('menubar', 'none',...
            'NumberTitle', 'off',...
            'name', 'Key Map',...
            'units', 'normalized',...
            'position', [0.025,0.05,0.2,0.3],...
            'Color', bgColor3,...
            'CloseRequestFcn', @closeWindow);
        
        
        
        labelStr = 'Select existing key to edit or select add hotkey';
        btnpos = [(x(1,1)), y(1,1), w*4, h];
        keyMapPrompt = uicontrol(keymap.window,...
            'Style', 'text',...
            'String', labelStr,...
            'Units', 'normalized',...
            'Position',btnpos,...
            'HorizontalAlignment', 'center',...
            'BackgroundColor', bgColor3);
        
        labelStr = 'Add Key';
        for count=1:length(PARAMS.keypress.DefaultKeys.Key)
            labelStr = [labelStr '|' num2str(PARAMS.keypress.DefaultKeys.Key(count).description)];
        end
        if isstruct(PARAMS.keypress.CtrlKeys)
            for count=1:length(PARAMS.keypress.CtrlKeys.Key)
                labelStr = [labelStr '|' num2str(PARAMS.keypress.CtrlKeys.Key(count).description)];
            end
        end
        if isstruct(PARAMS.keypress.AltKeys)
            for count=1:length(PARAMS.keypress.AltKeys.Key)
                labelStr = [labelStr '|' num2str(PARAMS.keypress.AltKeys.Key(count).description)];
            end
        end
        if isstruct(PARAMS.keypress.ShiftKeys)
            for count=1:length(PARAMS.keypress.ShiftKeys.Key)
                labelStr = [labelStr '|' num2str(PARAMS.keypress.ShiftKeys.Key(count).description)];
            end
        end
        
        btnpos = [(x(1,1)), y(2,1), w*3, h];
        keymap.existingKeys = uicontrol(keymap.window,...
            'Style', 'popupmenu',...
            'String', labelStr,...
            'Units', 'normalized',...
            'Position', btnpos,...
            'callback', @existingsKeys);
        
        btnpos = [x(1,1), y(3,1), w*3, h];
        keymap.radio = uibuttongroup('Position', btnpos, ...
            'Visible', 'off');
        
        btnAtt = {keymap.radio, ...
            'Style', 'radiobutton',...
            'Units', 'normalized',...
            'BackgroundColor', bgColor3,...
            };
        btnpos = [0, 0, 1, 1];
        keymap.defCheck = uicontrol(btnAtt{:},...
            'String', 'None',...
            'Position',btnpos,...
            'Tag', 'DefaultKeys');
        btnpos = [.25, 0, 1, 1];
        keymap.ctrlCheck = uicontrol(btnAtt{:},...
            'String', 'Ctrl',...
            'Position',btnpos,...
            'Tag', 'CtrlKeys');
        
        btnpos = [.50, 0, 1, 1];
        keymap.altCheck = uicontrol(btnAtt{:},...
            'Position', btnpos,...
            'String', 'Alt',...
            'Tag', 'AltKeys');
        
        btnpos = [.75, 0, 1, 1];
        keymap.shiftCheck = uicontrol(btnAtt{:},...
            'Position', btnpos,...
            'String', 'Shift',...
            'Tag', 'ShiftKeys');
        % btnpos = [.75, 0, 1, 1]
        % noneCheck = uicontrol(keymap.radio,...
        %     'Style'
        
        btnpos = [x(1,4), y(2,1), w, h];
        keymap.key = uicontrol(keymap.window,...
            'Style', 'edit',...
            'Units', 'normalized',...
            'Position', btnpos,...
            'BackgroundColor', bgColor1);
        
        btnpos = [x(1,4), y(3,1), w, h];
        keymap.keyTxt = uicontrol(keymap.window,...
            'Style', 'text',...
            'Units', 'normalized',...
            'Position', btnpos,...
            'String', 'Hotkey',...
            'BackgroundColor', bgColor3);
        
        labelStr = ['none'];
        btnpos = [x(1,1), y(5,1)+dsepy, w*2, h];
        group.pulldown = uicontrol(keymap.window,...
            'style', 'popupmenu',...
            'string', labelStr,...
            'units', 'normalized',...
            'position', btnpos, ...
            'HorizontalAlignment', 'left',...
            'BackgroundColor', bgColor1,...
            'callback', @populateGroup);
        
        %create a group text window
        labelStr = 'Group';
        btnpos = [x(1,1), y(4,1), w*2, h];
        group.txt =uicontrol(keymap.window,...
            'Style', 'text',...
            'String', labelStr,...
            'Units', 'normalized',...
            'Position', btnpos, ...
            'HorizontalAlignment', 'center',...
            'BackgroundColor', bgColor6);
        
        labelStr = 'Species';
        btnpos = [x(1,3), y(4,1), w*2, h];
        species.txt =uicontrol(keymap.window,...
            'style', 'text',...
            'string', labelStr,...
            'units', 'normalized',...
            'position', btnpos, ...
            'HorizontalAlignment', 'center',...
            'BackgroundColor', bgColor7);
        
        %create a species pull down menu
        labelStr = ['none'];
        btnpos = [x(1,3), y(5,1)+dsepy, w*2, h];
        species.pulldown = uicontrol(keymap.window,...
            'style', 'popupmenu',...
            'string', labelStr,...
            'units', 'normalized',...
            'position', btnpos, ...
            'HorizontalAlignment', 'left',...
            'BackgroundColor', bgColor1,...
            'callback',@populateSpecies);
        
        labelStr = ['Save'];
        btnpos = [x(1,1), y(16,1), w*2, h];
        savebutton = uicontrol(keymap.window,...
            'style', 'pushbutton',...
            'string', labelStr,...
            'units', 'normalized',...
            'position', btnpos,...
            'HorizontalAlignment', 'left',...
            'BackgroundColor', bgColor1,...
            'callback', @saveKeystroke);
        
        labelStr = ['Remove'];
        btnpos = [x(1,3), y(16,1), w*2, h];
        removebutton = uicontrol(keymap.window,...
            'style', 'pushbutton',...
            'string', labelStr,...
            'units', 'normalized',...
            'position', btnpos,...
            'HorizontalAlignment', 'left',...
            'BackgroundColor', bgColor1,...
            'callback', @removeKeystroke);
        
        
        labelStr = 'Call Types';
        btnpos = [x(1,1), y(13,1), 4*w, 9*h];
        keymap.speciesbuttons=uibuttongroup('parent',keymap.window,...
            'units', 'normalized',...
            'position', btnpos,...
            'backgroundcolor', bgColor5,...
            'Title', labelStr);
        
        keymap.loggerItems = [keymap.speciesbuttons species.pulldown species.txt group.txt...
            group.pulldown];
        set(keymap.radio, 'Visible', 'on')
        set(keymap.loggerItems, 'Visible', 'on')

        
        
        %need to switch to offeffort to make the chart right.
        if strcmp(PARAMS.log.mode, 'OffEffort')
            mkChart;
        else
            PARAMS.log.mode = 'OffEffort';
            mkChart;
            PARAMS.log.mode = 'OnEffort';
        end
    end
end

