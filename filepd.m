function filepd(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% filepd.m
%
% File pull-down menu options/operation
%
% Parameters:
%       action - the string that cooresponds to the action in the pulldown menu
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES DATA
if strcmp(action,'openltsa')
    ipnamesave = PARAMS.ltsa.inpath;
    ifnamesave = PARAMS.ltsa.infile;
    % user interface retrieve file to open through a dialog box
    boxTitle1 = 'Open LTSA File';
    filterSpec1 = '*.ltsa';
    [PARAMS.ltsa.infile,PARAMS.ltsa.inpath]=uigetfile(filterSpec1,boxTitle1);
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(PARAMS.ltsa.infile),'0')
        PARAMS.ltsa.inpath = ipnamesave;
        PARAMS.ltsa.infile = ifnamesave;
        return
    else % give user some feedback
        disp_msg('Opened File: ')
        disp_msg([PARAMS.ltsa.inpath,PARAMS.ltsa.infile])
        cd(PARAMS.ltsa.inpath)
    end
    % calculate the number of blocks in the opened file
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    PARAMS.ltsa.ftype = 1;
    if(get(HANDLES.display.ltsa,'Value'))
        if get(HANDLES.mc.on,'Value') || get(HANDLES.mc.lock, 'Value')
            set(HANDLES.mc.on,'Value', 0)
            set(HANDLES.mc.lock,'Value', 0)
        end
    end
    set(HANDLES.display.ltsa,'Visible','on')
    set(HANDLES.display.ltsa,'Value',1);
    set(HANDLES.ltsa.delimit.but,'Visible','on')
    control_ltsa('button')
    set([HANDLES.ltsa.motion.seekbof HANDLES.ltsa.motion.back HANDLES.ltsa.motion.autoback HANDLES.ltsa.motion.stop],...
        'Enable','off');
    init_ltsadata
    read_ltsadata
    PARAMS.plot.dnum = PARAMS.ltsa.plot.dnum;
    plot_triton
    %if link axes is on, lock all the axes zoom in together
    if get(HANDLES.mc.lock, 'Value') && get(HANDLES.mc.on,'Value')
        fig_hand = get(HANDLES.plot1,'Parent');
        all_hands = findobj(fig_hand, 'type', 'axes', 'tag', '');
        %add one for savalue so ltsa axis doesn't get linked
        all_hands (PARAMS.ch + 1) = 0;
        linkaxes(all_hands,'x');
    end
    control_ltsa('timeon')   % was timecontrol(1)
    % turn on other menus now
    control_ltsa('menuon')
    control_ltsa('ampon')
    control_ltsa('freqon')
    set(HANDLES.ltsa.motioncontrols,'Visible','on')
    set(HANDLES.ltsa.equal,'Visible','on')
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    
elseif strcmp(action,'openwav')
    % user interface retrieve file to open through a dialog box
    boxTitle1 = 'Open Wav or Flac File';
    filterSpec1 = {'*.wav;*.flac'};
    [infile,inpath]=uigetfile(filterSpec1,boxTitle1);
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(infile),'0')
        return
    else % give user some feedback
        PARAMS.infile = infile;
        PARAMS.inpath = inpath;
        disp_msg('Opened File: ')
        disp_msg([PARAMS.inpath,PARAMS.infile])
        cd(PARAMS.inpath)
    end
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    PARAMS.ftype = 1;
    % enter start date and time
    prompt={'Enter Start Date and Time'};
    dnums = wavname2dnum(PARAMS.infile);
    if isempty(dnums)
        PARAMS.start.dnum = datenum([0 1 1 0 0 0]);
    else
        PARAMS.start.dnum = dnums - datenum([2000 0 0 0 0 0]);
    end
    def={timestr(PARAMS.start.dnum,6)};
    dlgTitle=['Set Start for File : ',PARAMS.infile];
    lineNo=1;
    AddOpts.Resize='on';
    AddOpts.WindowStyle='normal';
    AddOpts.Interpreter='tex';
    in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
    if length(in) == 0	% if cancel button pushed
        PARAMS.cancel = 1;
        return
    end
    % time delay between Auto Display
    PARAMS.start.dnum=timenum(deal(in{1}),6);
    % initialize data format
    initdata
    if isempty(DATA)
        set(HANDLES.display.timeseries,'Value',1);
    end
    readseg
    plot_triton
    control('timeon')   % was timecontrol(1)
    % turn on other menus now
    control('menuon')
    control('button')
    set([HANDLES.motion.seekbof HANDLES.motion.back HANDLES.motion.autoback HANDLES.motion.stop],...
        'Enable','off');
    set(HANDLES.motioncontrols,'Visible','on')
    init_tslider(0)
    if PARAMS.nch > 1
        set(HANDLES.mc.on,'Visible','on');
        %         set(HANDLES.mc.off,'Visible','on');
    end
    
    % dialog box openxwav - open pseudo-wav file
elseif strcmp(action,'openxwav')
    % user interface retrieve file to open through a dialog box
    boxTitle1 = 'Open XWAV File';
    filterSpec1 = '*.x.wav';
    [ infile, inpath ]=uigetfile( filterSpec1, boxTitle1 );
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp( num2str( infile ), '0' )
        return
    else % give user some feedback
        % check for and close already opened FILES
        PARAMS.infile = infile;
        PARAMS.inpath = inpath;
        disp_msg('Opened File: ')
        disp_msg([PARAMS.inpath,PARAMS.infile])
        cd(PARAMS.inpath)
    end
    % calculate the number of blocks in the opened file
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    PARAMS.ftype = 2;
    initdata
    if ~isempty(PARAMS.xhd.byte_length)
        PARAMS.plot.initbytel = PARAMS.xhd.byte_loc(1);
    end
    if isempty(DATA)
        set(HANDLES.display.timeseries,'Value',1);
    end
    readseg
    plot_triton
    control('timeon')
    % turn on other menus now
    control('menuon')
    control('button')
    set([HANDLES.motion.seekbof HANDLES.motion.back HANDLES.motion.autoback HANDLES.motion.stop],...
        'Enable','off');
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.motioncontrols,'Visible','on')
    set(HANDLES.delimit.but,'Visible','on')
    if PARAMS.nch > 1
        set(HANDLES.mc.on,'Visible','on');
        %         set(HANDLES.mc.off,'Visible','on');
    elseif PARAMS.nch == 1
        set(HANDLES.multi,'Visible','off');
    else
        disp_msg(['Error number of channels : ', num2str(PARAMS.nch)])
    end
    init_tslider(0)
    % dialog box saveas into a file
elseif strcmp(action,'export_normwav')
    % user interface retrieve file to open through a dialog box
    boxTitle1 = 'Export Windowed Data As Normalized WAV File';
    outfiletype = '.wav';
    len = length(PARAMS.infile); % get input data file name
    fileName = 'data';
    [PARAMS.outfile,PARAMS.outpath]=uiputfile([fileName,outfiletype],boxTitle1);
    len = length(PARAMS.outfile);
    if len > 4 && ~strcmp(PARAMS.outfile(len-3:len),outfiletype)
        PARAMS.outfile = [PARAMS.outfile,outfiletype];
    end
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(PARAMS.outfile),'0')
        return
    else % give user some feedback
        
    end
    mxd = max(abs(DATA));
    
    if PARAMS.nBits == 16
        sf = 2^15 / mxd;
        wdata = int16(sf * DATA);
    elseif PARAMS.nBits == 24;
        wdata = int32(DATA);
    elseif PARAMS.nBits == 32
        wdata = int32(DATA);
    else
        disp_msg('PARAMS.nBits = ')
        disp_msg(PARAMS.nBits)
        disp_msg('not supported')
        return
    end
    %     wavwrite(wdata,PARAMS.fs,PARAMS.nBits,[PARAMS.outpath,PARAMS.outfile]);
    audiowrite([PARAMS.outpath,PARAMS.outfile],wdata,PARAMS.fs,'BitsPerSample',PARAMS.nBits);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action,'export_wav')
    % user interface retrieve file to open through a dialog box
    boxTitle1 = 'Export Windowed Data As WAV File';
    outfiletype = '.wav';
    len = length(PARAMS.infile); % get input data file name
    fileName = 'data';
    [PARAMS.outfile,PARAMS.outpath]=uiputfile([fileName,outfiletype],boxTitle1);
    len = length(PARAMS.outfile);
    if len > 4 && ~strcmp(PARAMS.outfile(len-3:len),outfiletype)
        PARAMS.outfile = [PARAMS.outfile,outfiletype];
    end
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(PARAMS.outfile),'0')
        return
    else % give user some feedback
        
    end
    
    if PARAMS.nBits == 16
        wdata = int16(DATA);
    elseif PARAMS.nBits == 24;
        wdata = int32(DATA);
    elseif PARAMS.nBits == 32
        wdata = int32(DATA);
    else
        disp_msg('PARAMS.nBits = ')
        disp_msg(PARAMS.nBits)
        disp_msg('not supported')
        return
    end
    %     wavwrite(wdata,PARAMS.fs,PARAMS.nBits,[PARAMS.outpath,PARAMS.outfile]);
    audiowrite([PARAMS.outpath,PARAMS.outfile],wdata,PARAMS.fs,'BitsPerSample',PARAMS.nBits);
    
    % dialog box saveas into a xwav file
elseif strcmp(action,'export_xwav')
    % user interface retrieve file to open through a dialog box
    boxTitle1 = 'Export Windowed Data As XWAV File';
    outfiletype = '.x.wav';
    len = length(PARAMS.infile); % get input data file name
    fileName = 'data';
    [PARAMS.outfile,PARAMS.outpath]=uiputfile([fileName,outfiletype],boxTitle1);
    len = length(PARAMS.outfile);
    if len > 4 && ~strcmp(PARAMS.outfile(len-5:len),outfiletype)
        PARAMS.outfile = [PARAMS.outfile,outfiletype];
    end
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(PARAMS.outfile),'0')
        return
    else % give user some feedback
        disp_msg('Write File: ')
        disp_msg([PARAMS.outpath,PARAMS.outfile])
    end
    if PARAMS.nBits == 16
        dtype = 'int16';
    elseif PARAMS.nBits == 24
        dtype = 'int24';
    elseif PARAMS.nBits == 32
        dtype = 'int32';
    else
        disp_msg('PARAMS.nBits = ')
        disp_msg(PARAMS.nBits)
        disp_msg('not supported')
        return
    end
    % write xwav header into output file
    wrxwavhd(1)
    % dump data to output file
    % open output file
    fod = fopen([PARAMS.outpath,PARAMS.outfile],'a');
    fwrite(fod,DATA,dtype);
    fclose(fod);
    
    % dialog box save plotted data to jpg file
elseif strcmp(action,'savejpg')
    % user interface retrieve file to open through a dialog box
    boxTitle1 = 'Save Plotted Data to JPG File';
    outfiletype = '.jpg';
    len = length(PARAMS.infile); % get input data file name
    [PARAMS.outfile,PARAMS.outpath]=uiputfile([PARAMS.infile(1:len-4),outfiletype],boxTitle1);
    len = length(PARAMS.outfile);
    if len > 4 && ~strcmp(PARAMS.outfile(len-3:len),outfiletype)
        PARAMS.outfile = [PARAMS.outfile,outfiletype];
    end
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(PARAMS.outfile),'0')
        return
    else % give user some feedback
        disp_msg('Write File: ')
        disp_msg([PARAMS.outpath,PARAMS.outfile])
    end
    %
    print (HANDLES.fig.main, '-djpeg100', '-r300',[PARAMS.outpath,PARAMS.outfile])
    
    % dialog box save plotted data to jpg file
elseif strcmp(action,'savepdf')
    % user interface retrieve file to open through a dialog box
    boxTitle1 = 'Save Plotted Data to PDF File';
    outfiletype = '.pdf';
    len = length(PARAMS.infile); % get input data file name
    [PARAMS.outfile,PARAMS.outpath]=uiputfile([PARAMS.infile(1:len-4),outfiletype],boxTitle1);
    len = length(PARAMS.outfile);
    if len > 4 && ~strcmp(PARAMS.outfile(len-3:len),outfiletype)
        PARAMS.outfile = [PARAMS.outfile,outfiletype];
    end
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(PARAMS.outfile),'0')
        return
    else % give user some feedback
        disp_msg('Write File: ')
        disp_msg([PARAMS.outpath,PARAMS.outfile])
    end
    %
    print (HANDLES.fig.main, '-dpdf',[PARAMS.outpath,PARAMS.outfile])
    
    % dialog box saveas into a figure file
elseif strcmp(action,'savefigureas')
    %Dialog Box Setup
    boxTitle1 = 'Save Figure As';
    outfiletype = '.fig';
    len = length(PARAMS.infile); % get input data file name
    %     fname = [PARAMS.infile(1:len-4) '@' strrep(strrep(datestr(PARAMS.start.dnum),':','-'),'.','_')];
    fname = PARAMS.infile(1:len-4);
    [PARAMS.outfile,PARAMS.outpath] = uiputfile( [fname,outfiletype], boxTitle1 );
    len = length(PARAMS.outfile);
    % Check for file extension
    if len > 4 && ~strcmp(PARAMS.outfile(len-3:len),outfiletype)
        PARAMS.outfile = [PARAMS.outfile,outfiletype];
    end
    % Display what we are going to write out
    disp_msg(['Write ' PARAMS.ioft ' File: '])
    disp_msg([PARAMS.outpath,PARAMS.outfile])
    % Check to see if the user hit the cancel button
    if strcmp(num2str(PARAMS.outfile),'0')
        return
    end
    % The name of the file
    name = [PARAMS.outpath,PARAMS.outfile];
    hgsave(HANDLES.fig.main,name);
    
    % dialog box saveas into a jpeg file
elseif strcmp(action,'saveimageas')
    %Dialog Box Setup
    boxTitle1 = 'Save Spectrogram Image As';
    outfiletype = ['.',PARAMS.ioft];
    len = length(PARAMS.infile); % get input data file name
    fname = [PARAMS.infile(1:len-4) '@' strrep(strrep(PARAMS.start.str,':','-'),'.','_')];
    [PARAMS.outfile,PARAMS.outpath] = uiputfile( [fname,outfiletype], boxTitle1 );
    len = length(PARAMS.outfile);
    % Check for file extension
    if len > 4 && ~strcmp(PARAMS.outfile(len-3:len),outfiletype)
        PARAMS.outfile = [PARAMS.outfile,outfiletype];
    end
    % Display what we are going to write out
    disp_msg(['Write ' PARAMS.ioft ' File: '])
    disp_msg([PARAMS.outpath,PARAMS.outfile])
    %     disp(' ')
    % Check to see if the user hit the cancel button
    if strcmp(num2str(PARAMS.outfile),'0')
        return
    end
    % Set the colormap
    if strcmp(PARAMS.cmap,'gray') % make negative colormap ie dark is big amp
        g = gray;
        szg = size(g);
        cmap = g(szg:-1:1,:);
        colormap(cmap)
    else
        colormap(PARAMS.cmap)
    end
    % Get the current colormap
    mapping = colormap;
    % Refresh the spectrogramdasf
    mkspecgram
    % Get the image, flip it so it writes out in the right orientation
    sg = (PARAMS.contrast/100) .* PARAMS.pwr + PARAMS.bright;
    sg = flipud(sg);
    % The name of the file
    name = [PARAMS.outpath,PARAMS.outfile];
    % Convert to true-color (IE do map lookup by hand)
    [a,b] = size(sg);
    sg = reshape(sg,1,a*b);
    sg( find(sg>length(mapping)) ) = length(mapping);
    sg( find(sg<1) ) = 1;
    % added round to provide integer access to mapping array smw 8/10/04
    sg=round(sg);
    sg = mapping(sg,:);
    tc = reshape(sg,a,b,3);
    % Write out the image
    if PARAMS.ioft == 'jpg'
        imwrite( tc, name, PARAMS.ioft, 'Quality', PARAMS.iocq );
    elseif PARAMS.ioft == 'tif'
        imwrite( tc, name, PARAMS.ioft, 'Compression', PARAMS.ioct );
    elseif PARAMS.ioft == 'hdf'
        if( strcmp(PARAMS.ioct,'jpeg') )
            imwrite( tc, name, PARAMS.ioft, 'Compression', PARAMS.ioct, 'Quality', PARAMS.iocq );
        else
            imwrite( tc, name, PARAMS.ioft, 'Compression', PARAMS.ioct );
        end
    elseif PARAMS.ioft == 'png'
        imwrite( tc, name, PARAMS.ioft, 'BitDepth', PARAMS.iobd );
    else
        imwrite( tc, name, PARAMS.ioft );
    end
    
    % Save messages into file
elseif strcmp(action,'savemsgs')
    % user interface retrieve file to open through a dialog box
    boxTitle1 = 'Save Messages to File';
    filterSpec1 = '*.msg.txt';
    [infile,inpath]=uiputfile(filterSpec1,boxTitle1);
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(infile),'0')
        return
    else % give user some feedback
        disp_msg('Message File: ')
        disp_msg([inpath,infile])
        msgs = char(get(HANDLES.msg,'String'));
        [mr,mc] = size(msgs);
        fid = fopen([inpath,infile],'w');
        for k = 1:mr
            fprintf(fid,'%s\r\n',msgs(k,:));
        end
        fclose(fid);
    end
    
    % Clear messages from display
elseif strcmp(action,'clrmsgs')
    lStr(1) = {['Triton ',PARAMS.ver]};
    lStr(2) = {'messages displayed here' };
    set(HANDLES.msg,'String',lStr,'Value',2);
    
    % Open Pick xyz into file
elseif strcmp(action,'openpicks')
    qstring{1} = 'Are you sure you want to Open a Pick file?';
    qstring{2} = 'Your current Picks will be overwritten';
    title = '!! Warning !!';
    default = 'Cancel';
    button = questdlg(qstring,title,default);
    if strcmp(button,'Yes')
        boxTitle1 = 'Open Picks File';
        filterSpec1 = '*.pik.txt';
        [infile,inpath]=uigetfile(filterSpec1,boxTitle1);
        % if the cancel button is pushed, then no file is loaded so exit this script
        if strcmp(num2str(infile),'0')
            disp_msg('Canceled Open Picks File')
            return
        else % give user some feedback
            disp_msg('Open Picks File: ')
            disp_msg([inpath,infile])
            fid = fopen([inpath,infile],'r');
            k = 0;
            while ~feof(fid)
                k = k+1;
                pick(k,:) = fgetl(fid);
            end
            fclose(fid);
            set(HANDLES.pick.disp,'String',cellstr(pick));
            PARAMS.inpath = inpath;     % change path
        end
    else
        return
    end
    
    % Save Pick xyz into file
elseif strcmp(action,'savepicks')
    boxTitle1 = 'Save Picks File';
    filterSpec1 = '*.pik.txt';
    [infile,inpath]=uiputfile(filterSpec1,boxTitle1);
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(infile),'0')
        disp_msg('Canceled Save Picks File')
        return
    else % give user some feedback
        disp_msg('Save Picks File: ')
        disp_msg([inpath,infile])
        pick = char(get(HANDLES.pick.disp,'String'));
        [pr,pc] = size(pick);
        fid = fopen([inpath,infile],'w');
        for k = 1:pr
            fprintf(fid,'%s\r\n',pick(k,:));
        end
        fclose(fid);
    end
elseif strcmp(action,'exit')
    close(HANDLES.fig.main)
    close(HANDLES.fig.ctrl)
    close(HANDLES.fig.msg)
    close all
end;
