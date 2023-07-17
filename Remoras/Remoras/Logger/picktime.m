function [time frequency] = picktime

% most of this code is ripped off from pickxyz

global handles HANDLES PARAMS

%start in plot figure window
figure(HANDLES.fig.main)
%user picks one point w/ crosshair
try
[x y]=ginput(1);

catch exception
    if(strcmp(exception.identifier,'MATLAB:ginput:Interrupted'))
        return
    else
        throw(exception);
    end
end

time = [];  % Assume nothing picked until we learn otherwise
frequency = [];


% get value for active windows
    savalue = get(HANDLES.display.ltsa,'Value');
    tsvalue = get(HANDLES.display.timeseries,'Value');
    spvalue = get(HANDLES.display.spectra,'Value');
    sgvalue = get(HANDLES.display.specgram,'Value');

    if tsvalue  % time series
        if gco == HANDLES.subplt.timeseries | gco == HANDLES.plt.timeseries...
                | gco == HANDLES.delimit.tsline
       
% unclear why this was set... perhaps problems w/ calclation???
%             time = [];
%             frequency = [];
%             return
%             %set filename for arctic logger
%             if isstr(PARAMS.infile)==1;
%                 handles.infilename=PARAMS.infile;
%             else handles.infilename=char(PARAMS.infile);
%             end

            % time from beginning of plot to delimitor line [seconds]
            rtime = (PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex) - PARAMS.plot.dnum)...
                * 60 *60 * 24;
            % convert x location into time for xwav
            if x < rtime
                ctime_dvec = datevec(PARAMS.plot.dnum) + [0 0 0 0 0 x];
            else
                dnum = PARAMS.raw.dnumStart(PARAMS.raw.currentIndex + 1);
                ctime_dvec = datevec(dnum) + [0 0 0 0 0 x-rtime];
            end
            HHMMSS = timestr(ctime_dvec,4);
            mmmuuu = timestr(ctime_dvec,5);
            
            %display pick value in start time text box
            time = ctime_dvec;
            frequency = [];
%             handles.strvec = ctime_dvec;
%             pick=[timestr(ctime_dvec,1)];%'    ',num2str(round(y))];
%             set(handles.pickstartdisplay, 'string', pick);
            
        end
    end
    if spvalue % spectra
        if gco == HANDLES.subplt.spectra | gco == HANDLES.plt.spectra
            ctime_dvec = datevec(PARAMS.plot.dnum);
            HHMMSS = timestr(ctime_dvec,4);
            freq = round(x);
            %display pick value in start time text box
%             handles.strvec = ctime_dvec;
%             pick=[timestr(ctime_dvec,1)];%'    ',num2str(freq),'Hz'];%,num2str(y,'%0.2f'),'dB'];
            time = ctime_dvec;
            frequency = [];
%             set(handles.pickstartdisplay, 'string', pick);
            
            %set filename for arcticlogger
            if isstr(PARAMS.infile)==1;
                handles.infilename=PARAMS.infile;
            else handles.infilename=char(PARAMS.infile);
            end
        end
    end

    if sgvalue % spectrogram
        if gco == HANDLES.subplt.specgram | gco == HANDLES.plt.specgram...
                | gco == HANDLES.delimit.sgline
            % time from beginning of plot to delimitor line [seconds]
            rtime = (PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex) - PARAMS.plot.dnum)...
                * 60 *60 * 24;
            % convert x location into time for xwav
            if x < rtime
                ctime_dvec = datevec(PARAMS.plot.dnum) + [0 0 0 0 0 x];
            else
                dnum = PARAMS.raw.dnumStart(PARAMS.raw.currentIndex + 1);
                ctime_dvec = datevec(dnum) + [0 0 0 0 0 x-rtime];
            end
            HHMMSS = timestr(ctime_dvec,4);
            mmmuuu = timestr(ctime_dvec,5);
            %set filename for arcticlogger
            if isstr(PARAMS.infile)==1;
                handles.infilename=PARAMS.infile;
            else handles.infilename=char(PARAMS.infile);
            end
            if length(PARAMS.t) > 1
                dt = PARAMS.t(2)-PARAMS.t(1);	%sec/pixel
                cp(1) = floor((x+dt/2)/dt) + 1 ;
            else
                cp(1) = 1;
            end
            df = PARAMS.f(2)-PARAMS.f(1);	%hz/pixel???
            cp(2) = floor((y - PARAMS.f(1) +df/2)/df)+1;
            szpwr = size(PARAMS.pwr);
            if (cp(1)>= 1 & cp(1) <= szpwr(2)) ...
                    & (cp(2) >= 1 & cp(2) <= szpwr(1))
                pwr = PARAMS.pwr(cp(2),cp(1));
            end
            
            %display pick value in start time text box
%             handles.strvec = ctime_dvec;
%             pick=[timestr(ctime_dvec,1)];%'   ',num2str(round(y)),...
                %'Hz'],num2str(pwr,'%0.1f'),'dB'];
            time = ctime_dvec;
            frequency = y;
%             set(handles.pickstartdisplay, 'string', pick);
%             set(handles.freqdisplay{1}, 'string', [num2str(y)]);
        end
    end

    if savalue % long term spectral average (neptune)
        if gco == HANDLES.subplt.ltsa | gco == HANDLES.plt.ltsa
            %set filename for arcticlogger
            if isstr(PARAMS.ltsa.infile)==1;
                handles.infilename=PARAMS.ltsa.infile;
            else handles.infilename=char(PARAMS.ltsa.infile);
            end
            % calc time

            % ctime_dnum = PARAMS.ltsa.start.dnum + x / 24;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
            %
            % new ltsa timing stuff 060514 smw:
            [rawIndex,tBin] = getIndexBin(x);
            % disp_msg([num2str(rawIndex),'  ',num2str(tBin)])

            tbinsz = PARAMS.ltsa.tave / (60*60);

            % cursor time in days (add one tBin to have 1st bin at zero
            ctime_dnum = PARAMS.ltsa.dnumStart(rawIndex) + (tBin - 0.5) * tbinsz /24;
            % disp_msg([num2str(ctime_dnum),'  ',num2str(tBin)])


            % get color power
            if length(PARAMS.ltsa.t) > 1
                dt = PARAMS.ltsa.t(2)-PARAMS.ltsa.t(1);	%sec/pixel
                cp(1) = floor((x+dt/2)/dt) + 1 ;
            else
                cp(1) = 1;
            end
            df = PARAMS.ltsa.f(2)-PARAMS.ltsa.f(1);	%hz/pixel???
            %   cp(2) = floor((cy+df/2)/df);
            cp(2) = floor((y - PARAMS.ltsa.f(1) +df/2)/df)+1;
            szpwr = size(PARAMS.ltsa.pwr);
            if (cp(1)>= 1 & cp(1) <= szpwr(2)) ...
                    & (cp(2) >= 1 & cp(2) <= szpwr(1))
                pwr = PARAMS.ltsa.pwr(cp(2),cp(1));
            end
            %display pick value in start time text box
%             handles.strvec = ctime_dnum;
%             pick=[timestr(ctime_dnum,1)];%'   ',num2str(round(y)),...
                %'Hz'];%,num2str(pwr,'%0.1f'),'dB'];
            time = ctime_dnum;
            frequency = y;
%             set(handles.pickstartdisplay, 'string', pick);
%             set(handles.freqdisplay{1}, 'string', [num2str(y)]);
        end
    end
