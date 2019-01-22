function effort_on_off

% most of this code is ripped off from pickxyz

global handles HANDLES PARAMS

%start in plot figure window
figure(HANDLES.fig.main)

if get(handles.effort_on_off, 'value')==1;
    set(handles.pickstart, 'enable', 'on');
    set(handles.pickend, 'enable', 'on');
    set(handles.eventlogbutton, 'enable', 'on');
    set(handles.savewavbutton, 'enable', 'on');
    set(handles.savexwavbutton, 'enable', 'on');
    set(handles.savejpegbutton, 'enable', 'on');
    set(handles.freq1, 'enable', 'on');
    set(handles.commentstext, 'enable', 'on');
    set(handles.effort_on_off, 'backgroundcolor', [0 0.95 0]);
    fakecalltype = 'start_effort';
    
elseif get(handles.effort_on_off, 'value')==0;
    set(handles.pickstart, 'enable', 'off');
    set(handles.pickend, 'enable', 'off');
    set(handles.eventlogbutton, 'enable', 'off');
    set(handles.savewavbutton, 'enable', 'off');
    set(handles.savexwavbutton, 'enable', 'off');
    set(handles.savejpegbutton, 'enable', 'off');
    set(handles.freq1, 'enable', 'off');
    set(handles.commentstext, 'enable', 'off');
    set(handles.effort_on_off, 'backgroundcolor', [0.95 0.25 0.2]);
    fakecalltype = 'end_effort';
end

%user picks one point w/ crosshair
[x y]=ginput(1);

% get value for active windows
    savalue = get(HANDLES.display.ltsa,'Value');
    tsvalue = get(HANDLES.display.timeseries,'Value');
    spvalue = get(HANDLES.display.spectra,'Value');
    sgvalue = get(HANDLES.display.specgram,'Value');

    if tsvalue  % time series
        if gco == HANDLES.subplt.timeseries | gco == HANDLES.plt.timeseries...
                | gco == HANDLES.delimit.tsline
            %set filename for call logger
            if isstr(PARAMS.infile)==1;
                handles.infilename=PARAMS.infile;
            else handles.infilename=char(PARAMS.infile);
            end
            % time from beginning of plot to delimitor line [seconds]
            rtime = (PARAMS.raw.dnumEnd(PARAMS.raw.currentIndex) - PARAMS.plot.dnum)...
                * 60 *60 * 24;
            % convert x location into time for xwav
            if x < rtime
                ctime_dvec = datevec(PARAMS.plot.dnum) + [2000 0 0 0 0 x];
            else
                dnum = PARAMS.raw.dnumStart(PARAMS.raw.currentIndex + 1);
                ctime_dvec = datevec(dnum) + [2000 0 0 0 0 x-rtime];
            end
            HHMMSS = timestr(ctime_dvec,4);
            mmmuuu = timestr(ctime_dvec,5);
            
            %if effort toggled on, get start effort from beginning of plot
            %window
            if get(handles.effort_on_off, 'value')==1;
                effortstartvec=PARAMS.plot.dvec;
                effortstartvec(1)=effortstartvec(1)+2000;
                efforttime=datestr(datenum(effortstartvec));
                
            %if going off effort, get end effort from user cursor pick
            elseif get(handles.effort_on_off, 'value')==0;
                efforttime=datestr(ctime_dvec);
            end
                    
           
            %display pick value in start time text box
            pick=[datestr(ctime_dvec,'mm/dd/yyyy HH:MM:SS.FFF')];%'    ',num2str(round(y))];
            set(handles.pickstartdisplay, 'string', pick);
            
        end
    end
    if spvalue % spectra
        if gco == HANDLES.subplt.spectra | gco == HANDLES.plt.spectra
            ctime_dvec = datevec(PARAMS.plot.dnum);
            HHMMSS = timestr(ctime_dvec,4);
            freq = round(x);
            %display pick value in start time text box
            pick=[timestr(ctime_dvec,6)];%'    ',num2str(freq),'Hz'];%,num2str(y,'%0.2f'),'dB'];
            set(handles.pickstartdisplay, 'string', pick);
            
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
                ctime_dvec = datevec(PARAMS.plot.dnum) + [2000 0 0 0 0 x];
            else
                dnum = PARAMS.raw.dnumStart(PARAMS.raw.currentIndex + 1);
                ctime_dvec = datevec(dnum) + [2000 0 0 0 0 x-rtime];
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
            %if effort toggled on, get start effort from beginning of plot
            %window
            if get(handles.effort_on_off, 'value')==1;
                effortstartvec=PARAMS.plot.dvec;
                effortstartvec(1)=effortstartvec(1)+2000;
                efforttime=datestr(datenum(effortstartvec));
                
            %if going off effort, get end effort from user cursor pick
            elseif get(handles.effort_on_off, 'value')==0;
                efforttime=datestr(ctime_dvec);
            end
            
            %display pick value in start time text box
            pick=[datestr(ctime_dvec,'mm/dd/yyyy HH:MM:SS.FFF')];%'   ',num2str(round(y)),...
                %'Hz'],num2str(pwr,'%0.1f'),'dB'];
            set(handles.pickstartdisplay, 'string', pick);
            set(handles.freqdisplay1, 'string', [num2str(y)]);
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
            %pick=[timestr(ctime_dnum,6)];
            rar=datenum([2000 0 0 0 0 0]);
            ctime_dnum2=ctime_dnum+rar;
            pick=[datestr(ctime_dnum2,'mm/dd/yyyy HH:MM:SS.FFF')];
            
            %if effort toggled on, get start effort from beginning of plot
            %window
            if get(handles.effort_on_off, 'value')==1;
            effortstartvec=PARAMS.ltsa.dvecStart(PARAMS.ltsa.plotStartRawIndex,:);
            effortstartvec(1)=effortstartvec(1)+2000;
            
            efforttime=datestr(datenum(effortstartvec));
            
            %if going off effort, get end effort from user cursor pick
            elseif get(handles.effort_on_off, 'value')==0;
                efforttime=datestr(ctime_dnum2);
            end
            
            %'   ',num2str(round(y)),...
                %'Hz'];%,num2str(pwr,'%0.1f'),'dB'];
            %set(handles.pickstartdisplay, 'string', pick);
            %set(handles.freqdisplay1, 'string', [num2str(y)]);
        end
    end
logefforttime(fakecalltype, efforttime)    
%sitename=sscanf(handles.infilename, '%[^_]');
%pickdate=datestr(pick,'yyyymmdd');
%picktime=datestr(pick,'HHMMSS');
%set(handles.outfiledisplay, 'string', [sitename '_' pickdate '_' picktime '_']);
%set(handles.timetypemenu, 'enable', 'on');