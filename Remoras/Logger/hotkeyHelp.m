function  hotkeyHelp( group, species, call )
% @author Erik Parreira
%
%This function takes in a group name, species name and calls and then switches the
%logger so the next detection is this species. If the passed in name is not
%on effort the logger switches to off effort. Also if the species is on
%effrot but you are logging off, it will switch back to on effort. While
%technically can be called anywhere as long as the log is open, it's mainly
%called by the handleHotkey function (hence the name)

global PARAMS HANDLES handles TREE
isInEffort = inEffort;%used twice so saved for future use
if isInEffort
    if strcmp(PARAMS.log.mode, 'OffEffort')
        %the call is OnEffort but current logging offEffort
        control_log('adhoc');%Swittch to onEffort
    end
else
    if strcmp(PARAMS.log.mode, 'OnEffort')
        %the call is offeffort but we are currently on effort
        control_log('adhoc');%switch to off effort
    end
end
groupNames = get(handles.group.pulldown, 'string');
groupIdx = find(strcmp(group, groupNames));
set(handles.group.pulldown, 'Value', groupIdx);
control_log('group');

speciesNames = get(handles.species.pulldown, 'string');
speciesIdx = find(strcmp(species, speciesNames));
set(handles.species.pulldown, 'Value', speciesIdx);
control_log(handles.species.pulldown, [], 'species');

callNames = get(handles.calltype, 'string');
callIdxs = find(ismember(callNames,call));
for x = 1:length(callIdxs)
    set(handles.calltype(callIdxs(x)), 'value', 1);
end
% callIdx = find(strncmp(call,callNames, length(call)));
% set(handles.calltype(callIdx), 'value', 1);
call_checkbox;

    function boolean = inEffort
        %first checks if the call is on effort
        for x = 1:length(TREE.effort)
            if strcmp(group, TREE.effort{x}.name)
                for y = 1:length(TREE.effort{x}.species)
                    if strcmp(species, TREE.effort{x}.species{y}.name)
                        logicalCall = ismember(call, TREE.effort{x}.species{y}.calls);
                        if any(logicalCall == 0)
                            boolean = 0;
                            return; %not all the calls are in the effort
                        else
                            boolean = 1;
                            return;
                        end
                    end
                end
            end
            
        end
        boolean = 0;
    end

    function call_checkbox
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
        
    end

end