function pwr = sh_read_ltsadata(handles,start,stop)
%
% sh_read_ltsadata.m
%
% reads the ltsa data portion of the file. Data calculated like in the
% Remora, and then data portion is selected

dnum2sec = 24*60*60;
doff = datenum([2000 0 0 0 0 0]); % convert to matlab dates

start = start-doff;
stop = stop-doff;

durWind = (stop-start)*dnum2sec;

% If it goes passed lenght ltsa, set end ltsa as end of window 
if stop > handles.ltsa.end.dnum
   durWind = (handles.ltsa.end.dnum - start)* dnum2sec; 
end

fid = fopen(fullfile(handles.LtsaPath,handles.LtsaFile),'r');

nbin = floor(durWind / handles.ltsa.tave); 

% find which raw file window start time (startDnumWind) is in
startIndex = [];
startIndex = find(start >= handles.ltsa.dnumStart ...
     & start + datenum([0 0 0 0 0 handles.ltsa.tave])  <= handles.ltsa.dnumEnd, 1);

% if the window start time is not within a raw file (i.e., non-recording 
% time between raw files),find which ones it is between 
if isempty(startIndex)
    startIndex = min(find(start <= handles.ltsa.dnumStart));
    start = handles.ltsa.dnumStart(startIndex);
end

%
% time bin number at start of window within rawfile (index)
startBin = floor((start - ....
    handles.ltsa.dnumStart(startIndex)) * dnum2sec ...
    / handles.ltsa.tave) + 1;

% samples to skip over in ltsa file
skip = handles.ltsa.byteloc(startIndex) + ....
    (startBin - 1) * handles.ltsa.nf;

status = fseek(fid,skip,-1);    % skip over header + other data
if status == -1
    finfo = dir(fullfile(handles.LtsaPath,handles.LtsaFile));
    msg_str = sprintf('LTSA read byteloc %d failed, file size = %d bytes', ...
        skip, finfo.bytes);
    disp_msg(msg_str);
end

pwr = fread(fid,[handles.ltsa.nf,nbin],'int8');   % read data

fclose(fid);