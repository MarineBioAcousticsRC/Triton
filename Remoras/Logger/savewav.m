function savewav

% write spectrogram data into a wav file with same title as event number

global handles PARAMS DATA

if strcmp(get(handles.eventnumber, 'string'), '');
    errordlg('Please enter initials')
    set(handles.savewavbutton, 'value', 0);
    return
end

if strcmp(get(handles.pickstartdisplay, 'string'),'');
    errordlg('Please pick time')
    set(handles.savewavbutton, 'value', 0);
    return
end

%if strcmp(get(handles.endtimedisplay, 'string'),'');
%    errordlg('Please pick end time')
%    set(handles.savewavbutton, 'value', 0);
%    return
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% user interface retrieve file to open through a dialog box
boxTitle1 = 'Windowed Data Save As WAV';
outfiletype = '.wav';
len = length(PARAMS.infile); % get input data file name
fileName = handles.outfilename;
[PARAMS.outfile,PARAMS.outpath]=uiputfile([fileName,outfiletype],boxTitle1);
len = length(PARAMS.outfile);
if len > 4 & ~strcmp(PARAMS.outfile(len-3:len),outfiletype)
    PARAMS.outfile = [PARAMS.outfile,outfiletype];
end
% if the cancel button is pushed, then no file is loaded so exit this script
if strcmp(num2str(PARAMS.outfile),'0')
    set(handles.savewavbutton, 'value', 0);
    return
else % give user some feedback
    disp_msg('Write File: ')
    disp_msg([PARAMS.outpath,PARAMS.outfile])
end
% MATLAB wavwrite requires input vector to be max +/- 1
%
% max of dat so not to clip
% this mode is for normalizes to maximum amplitude (volume)
% dmx = max(abs(DATA));
%
% normalize to max count (16-bit => +/- 2^15 (32768))
dmx = 2^15;

% write wave file
%     wavwrite(DATA./dmx,PARAMS.fs,[PARAMS.outpath,PARAMS.outfile]);
audiowrite([PARAMS.outpath,PARAMS.outfile],DATA./dmx,PARAMS.fs);