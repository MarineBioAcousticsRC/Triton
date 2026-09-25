function info_struct = coorddisp_2(return_data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global info PARAMS HANDLES
%checks to see if there are plots open, if no plots open, returns 0
if ~isfield(HANDLES, 'subplt') || ~isfield(HANDLES, 'plt')
    % no plots open, return.
    info.proc = 0;
    return
end
%location of current axis and current point
current_axis_point = get(get(HANDLES.fig.main,'CurrentAxes'),'CurrentPoint');
cx = current_axis_point(1,1);
cy = current_axis_point(1,2);
xlim = get(get(HANDLES.fig.main,'CurrentAxes'),'XLim');
ylim = get(get(HANDLES.fig.main,'CurrentAxes'),'YLim');
info.proc = 0;

%Check if cursor outside of plots
if cx < xlim(1) | cx > xlim(2) | cy < ylim(1) | cy > ylim(2)
    set(HANDLES.coorddisp,'Visible','off')
    set(HANDLES.ltsa.coorddisp,'Visible','off')
    return % not in plot
end

button = get(HANDLES.fig.main, 'SelectionType');
savalue = get(HANDLES.display.ltsa,'Value');
tsvalue = get(HANDLES.display.timeseries,'Value');
spvalue = get(HANDLES.display.spectra,'Value');
sgvalue = get(HANDLES.display.specgram,'Value');

% following code executes based on which plot is clicked with cursor
%(ie:LTSA or Spectogram)

% % LTSA
% if savalue
%   if (ishandle(HANDLES.subplt.ltsa) & gco == HANDLES.subplt.ltsa) | ...
%       (ishandle(HANDLES.plt.ltsa) & gco == HANDLES.plt.ltsa)
%%%%%CAN'T FIND WHERE LTSA_PICK IS WRITTEN%%%%%%%%
%     ltsa_pick(cx, cy);
%     return
%   end
% end

%% Spectogram
MultiCh_On = get(HANDLES.mc.on, 'Value');
if sgvalue
    if MultiCh_On
        if gco == HANDLES.subplt.specgram | gco == HANDLES.plt.specgram | ...
                get(gcf,'CurrentAxes') == HANDLES.plot1||...
                get(gcf,'CurrentAxes') == HANDLES.plot2||...
                get(gcf,'CurrentAxes') == HANDLES.plot3||...
                get(gcf,'CurrentAxes') == HANDLES.plot4||...
                (~isempty(gco) & find(HANDLES.delimit.sgline==gco))
            if PARAMS.ftype ~= 1
                time = get_time_xwav(cx);
            else
                time = get_time_wav(cx);
            end
            info.values = calc_and_disp_values('sg', time, cx, cy);
            return;
        end
    else
        if gco == HANDLES.subplt.specgram | gco == HANDLES.plt.specgram | ...
                (~isempty(gco) & find(HANDLES.delimit.sgline==gco))
            if PARAMS.ftype ~= 1
                time = get_time_xwav(cx);
            else
                time = get_time_wav(cx);
            end
            info = calc_and_disp_values('sg', time, cx, cy);
            return;
        end
    end
end
end

function time_vec = get_time_wav(x_coord)
    time_vec = datevec(PARAMS.plot.dnum) + [0 0 0 0 0 x_coord];
end

function time_vec = get_time_xwav(x_coord)
    % Finds the time vector that cooresponds to where the cursor is in the plot
    % input:
    %       x_coord - the x coordinate of the cursor
    % return:
    %       time_vec - the vector where the cursor is
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 151112 smw - fixed for non-full raw files
    % PARAMS.raw.currentIndex is the raw file number of the start of plot
    % PARAMS.raw.delimit_time is the amount of time from plot origin to next
    % rawfile.  If one delimiter is shown, there will be two times in
    % variable, and so on
    ndelim = length(PARAMS.raw.delimit_time) - 1;  % number of delimiters displayed
    if ndelim == 0      % only one raw file selectable in display plot
        time_vec = datevec(PARAMS.plot.dnum) + [0 0 0 0 0 x_coord];
    else
        I = []; J = [];
        I = find(x_coord < PARAMS.raw.delimit_time, 1, 'first'); % figure out where pick is compared to delimiters
        if ~isempty(I)
            if I == 1                       % pick in first raw file displayed, same as no delimiters
                x_delta = 0;
                dnumStart =  PARAMS.plot.dnum;
            else                            % pick after the first delimiter
                x_delta = PARAMS.raw.delimit_time(I-1);
                dnumStart = PARAMS.raw.dnumStart(PARAMS.raw.currentIndex + I-1) ;
            end
            x_rel = x_coord - x_delta;
            time_vec = datevec(dnumStart) + [0 0 0 0 0 x_rel];
        else
            disp_msg('Error: pick time > all PARAMS.raw.delimit_time')
        end
    end
end

function info_struct = calc_and_disp_values(plot_clicked, time_vec, x_coord, y_coord )
    % Handles displaying the values in the message window.
    % input:
    %       plot_clicked - which plot (timeseries, spectra etc) is clicked
    %       time_vec - the vector of time that will be displayed
    %       x_coord - the x coordinate of where the cursor is
    %       y_coord - the y coordinate of where the cursor is
    global info HANDLES
    HHMMSS = timestr(time_vec,4);
    mmmuuu = timestr(time_vec,5);
    mmmuuu = round_to_sample(mmmuuu, 1 / PARAMS.fs); % round to sample

    % update time values
    set(HANDLES.coord.bg,'Visible','on');
    set(HANDLES.coord.txt1,'String',HHMMSS);
    set(HANDLES.coord.txt1b,'String',mmmuuu);
    set(HANDLES.coord.lbl1,'Visible','on');
    set(HANDLES.coord.lbl1b,'Visible','on');
    set(HANDLES.coord.txt1,'Visible','on');
    set(HANDLES.coord.txt1b,'Visible','on');

    % display different info depending on which plot is active
    switch plot_clicked
        case 'sg'
            set(HANDLES.coord.lbl2,'Visible','on');
            set(HANDLES.coord.txt2,'Visible','on');
            set(HANDLES.coord.lbl3,'Visible','on');
            set(HANDLES.coord.txt3,'Visible','on');
            set(HANDLES.coord.txt2,'String',num2str(round(y_coord),'%d'))
            set(HANDLES.coord.lbl2,'String',{'Freq';' [Hz] '});
            if MultiCh_On
                set(HANDLES.coord.lbl4, 'Visible', 'on');
                savalue = get(HANDLES.display.ltsa,'Value');
                for ch = 1+savalue:PARAMS.nch+savalue
                    handle_num = eval(sprintf('HANDLES.axes%d.handle',ch));
                    if handle_num == gca
                        ch_num = eval(sprintf('HANDLES.axes%d.ch',ch));
                        if savalue
                            ch_num = ch_num - 1;
                        end
                    end
                end
                set(HANDLES.coord.txt4, 'Visible', 'on');
                set(HANDLES.coord.txt4, 'String', ch_num);
            end
            % calculate and dislpay the frequency
            if length(PARAMS.t) > 1
                dt = PARAMS.t(2)-PARAMS.t(1);	% sec/pixel
                cp(1) = floor((x_coord+dt/2)/dt) + 1 ;
            else
                cp(1) = 1;
            end
            df = PARAMS.f(2)-PARAMS.f(1);	% hz/pixel???
            cp(2) = floor((y_coord - PARAMS.f(1) +df/2)/df)+1;
            szpwr = size(PARAMS.pwr);
            if (cp(1)>= 1 & cp(1) <= szpwr(2)) ...
                    & (cp(2) >= 1 & cp(2) <= szpwr(1))
                pwr = PARAMS.pwr(cp(2),cp(1));
                set(HANDLES.coord.txt3,'String',num2str(pwr,'%0.1f'));
                set(HANDLES.coord.lbl3,'String','S Level [dB]');
            end
            if return_data
                info.plot = 'sg';
                info.time_vec = time_vec;
                info.time = timestr(time_vec,8);
                info.db = pwr;
                info.freq = round(y_coord);
                info.proc = 1;
            end
    end
    if ~return_data
        info.proc = 0;
    end
end

function ltsa_pick(cx, cy)
    % Handles ltsa display.
    % input:
    %       cx - the location of the x coordinate
    %       cy - the location of the y coordinate
    global info
    set(HANDLES.ltsa.coord.bg,'Visible','on');
    set(HANDLES.ltsa.coord.lbl1,'Visible','on');
    set(HANDLES.ltsa.coord.txt1,'Visible','on');
    set(HANDLES.ltsa.coord.lbl1b,'Visible','on');
    set(HANDLES.ltsa.coord.txt1b,'Visible','on');
    set(HANDLES.ltsa.coord.lbl2,'Visible','on');
    set(HANDLES.ltsa.coord.txt2,'Visible','on');
    set(HANDLES.ltsa.coord.lbl3,'Visible','on');
    set(HANDLES.ltsa.coord.txt3,'Visible','on')

    [rawIndex,tBin] = getIndexBin(cx);
    tbinsz = PARAMS.ltsa.tave / (60*60);

    % cursor time in days (add one tBin to have 1st bin at zero
    ctime_dnum = PARAMS.ltsa.dnumStart(rawIndex) + (tBin - 0.5) * tbinsz /24;
    set(HANDLES.ltsa.coord.txt1,'String',timestr(ctime_dnum,3));
    set(HANDLES.ltsa.coord.txt1b,'String',timestr(ctime_dnum,4));
    set(HANDLES.ltsa.coord.txt2,'String',num2str(round(cy),'%d'))

    if length(PARAMS.ltsa.t) > 1
        dt = PARAMS.ltsa.t(2)-PARAMS.ltsa.t(1);	%sec/pixel
        cp(1) = floor((cx+dt/2)/dt) + 1 ;
    else
        cp(1) = 1;
    end
    df = PARAMS.ltsa.f(2)-PARAMS.ltsa.f(1);	%hz/pixel???
    cp(2) = floor((cy - PARAMS.ltsa.f(1) +df/2)/df)+1;
    szpwr = size(PARAMS.ltsa.pwr);
    if (cp(1)>= 1 & cp(1) <= szpwr(2)) ...
            & (cp(2) >= 1 & cp(2) <= szpwr(1))
        pwr = PARAMS.ltsa.pwr(cp(2),cp(1));
        set(HANDLES.ltsa.coord.txt3,'String',num2str(pwr,'%0.1f'));
    end
    if return_data
        info.plot = 'sa';
        info.time = [timestr(ctime_dnum,3) ' ' timestr(ctime_dnum,4)];
        info.time_vec = datevec(ctime_dnum);
        info.db = pwr;
        info.freq = round(cy);
        info.proc = 1;
    end
end

function rounded = round_to_sample(mmmuuu, inv_fs)
    % rounds the mmmuuu seconds to the closest multiple of the sample rate.
    % input:
    %     mmmuuu - the numer to round
    %     inv_fs - inverse sample rate (the rate of seconds per sample)
    % output: rounded - a string representation of the rounded number
    multiple = inv_fs * 1000000; % easier to work will whole numbers
    rounded = round(str2num(mmmuuu)*1000);
    % fix if not a multiple
    if mod(rounded, multiple) >= multiple / 2
        rounded = rounded + multiple - mod(rounded, multiple);
    elseif mod(rounded, multiple) < multiple / 2 && mod(rounded, multiple) ~= 0
        rounded = rounded - mod(rounded, multiple);
    end
    rounded = round(rounded) / 1000;
    rounded = sprintf('%07.3f', rounded); % add leading and trailing zeros
end

