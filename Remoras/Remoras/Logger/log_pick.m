function log_pick(time, freq, fname)
% log_pick(time, freq)
% Callback for all logger time/frequency selections

global PARAMS handles

pick = PARAMS.log.pick;  % what type of pick

if ~ isempty(time)
    time = time+dateoffset;  % Change from Triton date to std Matlab date
end

% If the start time is after the stop time, swap them.
if time(1) > time(2)
    tmpt = time(1);
    time(1) = time(2);
    time(2) = tmpt;
    if ~isempty(freq)
        tmpf = freq(1);
        freq(1) = freq(2);
        freq(2) = tmpf;
    end
end
    
switch pick 
    case 'timeXfreq'
        % Store the current time and frequency and source file
        % with the last picked time frequency widget

        
        for idx = 1:length(time)
        
            tf.time = time(idx);
            %tf.timeidx = timeidx(idx);
            tf.src_file = fname;  % Picked in which file?
            
            % Format the time-frequency selection and update the display
            % widgets
            
            if isempty(freq)
                freqstr = 'NA';
                tf.freq = [];
               % tf.freqidx = [];
            else
                tf.freq = freq(idx);
                if freq(idx) > 1000
                    freqstr = sprintf('%.3f kHz', freq(idx)/1000);
                else
                    freqstr = sprintf('%.1f Hz', freq(idx));
                end
               % tf.freqidx = freqidx(idx);
            end
            
            timeXfreqStr = sprintf('%s  %s', ...
                datestr(time(idx), 'YYYY-mm-DD HH:MM:SS.FFF'), freqstr);
            
            set(handles.timefreq(idx), 'String', timeXfreqStr, ...
                'UserData', tf);
            
            
            
            if idx == 1 && get(handles.pkfreq, 'Value')
                % Record time frequency in scratch log
                log = get(handles.pkfreqdisplay, 'String');
                log{end+1} = timeXfreqStr;
                set(handles.pkfreqdisplay, 'String', log, 'Value', length(log));
            end
        end

        
        % todo:  Move this into pickxyz as we do not have access to 
        % the normalized coordinates here
%         if ~ isempty(PARAMS.log.lastpick) && ishandle(PARAMS.log.lastpick(1))
%             delete(PARAMS.log.lastpick);
%         end
%         circlesN = 3;
%         PARAMS.log.lastpick = zeros(circlesN, 1);
%         for idx = 1:circlesN
%             circle([x, y], .05*idx, 80, 'w-');
%         end
    case 'effort_start'
        if ishandle(handles.effort_start.disp)
            set(handles.effort_start.disp, 'String', ...
                datestr(time(1), 'YYYY-mm-DD HH:MM:SS.FFF'));
        end
        
    case 'effort_end'
        PARAMS.log.end = datestr(time(1), 'YYYY-mm-DD HH:MM:SS.FFF');
        set(handles.effort_end.disp, 'String', ...
                datestr(time(1), 'YYYY-mm-DD HH:MM:SS.FFF'));

end

pickxyz(true);  % Set up pointer appropriately








