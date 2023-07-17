function [pwr,startIndex,startBin] = sh_get_pwr_window(dnumSnippet)

global REMORA

dnum2sec = 24*60*60;
durWind = REMORA.sh.settings.durWind;

endDnumWind = dnumSnippet + datenum([0 0 0 0 0 durWind]);

if endDnumWind > REMORA.sh.ltsa.end.dnum
   durWind = (REMORA.sh.ltsa.end.dnum - dnumSnippet)* dnum2sec; 
end


ltsaFullFile = fullfile(REMORA.sh.ltsa.inpath, REMORA.sh.ltsa.infile);

fid = fopen(ltsaFullFile,'r');

nbin = floor(durWind / REMORA.sh.ltsa.tave); 

% find which raw file window start time (startDnumWind) is in
startIndex = [];
startIndex = find(dnumSnippet >= REMORA.sh.ltsa.dnumStart ...
     & dnumSnippet + datenum([0 0 0 0 0 REMORA.sh.ltsa.tave])  <= REMORA.sh.ltsa.dnumEnd, 1);

% if the window start time is not within a raw file (i.e., non-recording time between raw files),
% find which ones it is between 
if isempty(startIndex)
    startIndex = min(find(dnumSnippet <= REMORA.sh.ltsa.dnumStart));
    dnumSnippet = REMORA.sh.ltsa.dnumStart(startIndex);
end

%
% time bin number at start of window within rawfile (index)
startBin = floor((dnumSnippet - ....
    REMORA.sh.ltsa.dnumStart(startIndex)) * 24 * 60 * 60 ...
    / REMORA.sh.ltsa.tave) + 1;

% samples to skip over in ltsa file
skip = REMORA.sh.ltsa.byteloc(startIndex) + ....
    (startBin - 1) * REMORA.sh.ltsa.nf;

status = fseek(fid,skip,-1);    % skip over header + other data
if status == -1
    finfo = dir(ltsaFullFile);
    msg_str = sprintf('LTSA read byteloc %d failed, file size = %d bytes', ...
        skip, finfo.bytes);
    disp_msg(msg_str);
end

pwr = fread(fid,[REMORA.sh.ltsa.nf,nbin],'int8');   % read data

fclose(fid);