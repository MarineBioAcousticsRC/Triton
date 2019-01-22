function audvidplayer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% audvidplayer.m
%
% stolen from audiosnd.m
%
% play sound of DATA vector (ie plotted data only)
%
% need audioplayer (Matlab 6 and above)
%
% 060205 060227 smw
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS DATA

if PARAMS.nch > 1
    data = DATA(:,PARAMS.ch);
else
    data = DATA;
end

control('menuoff');
control('buttoff');
% turn Stop button back on
set(HANDLES.snd.stop,'Userdata',1);
set(HANDLES.fig.ctrl, 'Pointer', 'watch'); % put pointer to watch
% open up new window and plot data for PARAMS.ptype
% window placement & size on screen
defaultPos=[0.333,0.1,0.65,0.80];

figure(HANDLES.fig.main)

maxfs = 200e3;  % limits imposed by mathworks starting matlab 2012a
minfs = 1000;


% Kludge for playing fs > maxfs
if PARAMS.fs > maxfs 
    df =  ceil(PARAMS.fs/maxfs);
    disp_msg(sprintf('Downsampling data by factor of %d for playback\n',df));
    data_play = decimate(data,df);
    data_fs = PARAMS.fs/df;
else
    data_play = data;
    data_fs = PARAMS.fs;
end

% length of data segment to play
len = length(data_play);

% playback sample rate
playfs = data_fs * PARAMS.speedFactor;
if playfs > maxfs
  PARAMS.speedFactor = floor(maxfs/data_fs);
  disp_msg(sprintf('Lowering speed to %3.2f for playback', PARAMS.speedFactor)); 
  playfs = data_fs * PARAMS.speedFactor; 
  set(HANDLES.snd.edtxt,'String',num2str(PARAMS.speedFactor));
elseif playfs < minfs
  PARAMS.speedFactor = ceil(minfs/data_fs);
  disp_msg(sprintf('Increasing speed to %3.2f for playback', PARAMS.speedFactor));
  playfs = data_fs * PARAMS.speedFactor;
  set(HANDLES.snd.edtxt,'String',num2str(PARAMS.speedFactor));  
end


% adjust the volume
sdata = int16((PARAMS.sndVol * (2^16) / (max(data_play) - min(data_play))) .* data_play);
% sdata = DATA;

% start audio player
aplay = audioplayer(sdata,playfs);

savalue = get(HANDLES.display.ltsa,'Value');
tsvalue = get(HANDLES.display.timeseries,'Value');
spvalue = get(HANDLES.display.spectra,'Value');
sgvalue = get(HANDLES.display.specgram,'Value');

rflag = 0;

if tsvalue & ~sgvalue % timeseries
% check for plot type and set up plot and animation parameters
    HANDLES.plt.timeseries = plot((0:len-1)/data_fs,data_play);
    v = axis;
    y = [v(3),v(4)];
    x = [0,0];
    % line for animation
    h = line(x,y,'Color','r','LineWidth',4);
    rflag = 1;
elseif spvalue & ~tsvalue & ~ sgvalue
    disp_msg('sound player not supported with spectra plot')
elseif savalue & ~tsvalue & ~sgvalue
    disp_msg('sound player not supported with long-term spectra average plot')
elseif sgvalue & ~tsvalue
    time = get(HANDLES.plt.specgram,'XData');
    freq = get(HANDLES.plt.specgram,'YData');
    sg = get(HANDLES.plt.specgram,'CData');
    HANDLES.plt.specgram = image(time,freq,sg);
    axis xy
    y = [min(freq),max(freq)];
    x = [0,0];
    % line for animation
    h = line(x,y,'Color','k','LineWidth',4);
    rflag = 1;
elseif tsvalue & sgvalue
    % timeseries plot
    subplot(HANDLES.subplt.timeseries);
    HANDLES.plt.timeseries = plot((0:len-1)/data_fs,data_play);
    v = axis;
    y = [v(3),v(4)];
    x = [0,0];
    % line for animation
    h = line(x,y,'Color','r','LineWidth',4);
    % Spectrogram plot
    time = get(HANDLES.plt.specgram,'XData');
    freq = get(HANDLES.plt.specgram,'YData');
    sg = get(HANDLES.plt.specgram,'CData');
    subplot(HANDLES.subplt.specgram);
    HANDLES.plt.specgram = image(time,freq,sg);
    axis xy
    y2 = [min(freq),max(freq)];
    x = [0,0];
    % line for animation
    h2 = line(x,y2,'Color','k','LineWidth',4);
    rflag = 2;
end % end if PARAMS.ptype

if rflag == 1 | rflag == 2 
    % start audio playing the data segment
    play(aplay)
    % do animation and keep player running until done of button pushed
    while get(HANDLES.snd.stop,'Userdata') == 1 & isplaying(aplay)
        x = [1,1] .* PARAMS.tseg.sec * get(aplay,'CurrentSample')/len;
        set(h,'Xdata',x,'Ydata',y)
        % update other plot for timeseries + spectrogram
        if rflag == 2
            set(h2,'Xdata',x,'Ydata',y2)
        end
        drawnow
    end
end


%close the sound/figure window
set(HANDLES.fig.ctrl, 'Pointer', 'arrow'); % put pointer back
control('menuon')
control('button')
set(HANDLES.snd.stop,'Enable','off');	% turn off Play Stop button
set(HANDLES.snd.play,'Enable','on');    % turn Sound Play button back on
