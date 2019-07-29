function pwr = fn_pwrSnippet(startDnumWind)

global REMORA

dnum2sec = 24*60*60;
durWind = REMORA.ship_dt.settings.durWind;

endDnumWind = startDnumWind + datenum([0 0 0 0 0 durWind]);

if endDnumWind > REMORA.ship_dt.ltsa.end.dnum
   durWind = (REMORA.ship_dt.ltsa.end.dnum - startDnumWind)* dnum2sec; 
end


ltsaFullFile = fullfile(REMORA.ship_dt.ltsa.inpath, REMORA.ship_dt.ltsa.infile);

fid = fopen(ltsaFullFile,'r');

nbin = floor(durWind / REMORA.ship_dt.ltsa.tave); 

% find which raw file window start time (startDnumWind) is in
startRawIndexWind = find(startDnumWind >= REMORA.ship_dt.ltsa.dnumStart ...
     & startDnumWind + datenum([0 0 0 0 0 REMORA.ship_dt.ltsa.tave])  <= REMORA.ship_dt.ltsa.dnumEnd, 1);

% if the window start time is not within a raw file (i.e., non-recording time between raw files),
% find which ones it is between 
if isempty(startRawIndexWind)
    startRawIndexWind = min(find(startDnumWind <= REMORA.ship_dt.ltsa.dnumStart));
    startDnumWind = REMORA.ship_dt.ltsa.dnumStart(startRawIndexWind);
end

%
% time bin number at start of window within rawfile (index)
startBinWind = floor((startDnumWind - ....
    REMORA.ship_dt.ltsa.dnumStart(startRawIndexWind)) * 24 * 60 * 60 ...
    / REMORA.ship_dt.ltsa.tave) + 1;

% samples to skip over in ltsa file
skip = REMORA.ship_dt.ltsa.byteloc(startRawIndexWind) + ....
    (startBinWind - 1) * REMORA.ship_dt.ltsa.nf;

status = fseek(fid,skip,-1);    % skip over header + other data
if status == -1
    finfo = dir(ltsaFullFile);
    msg_str = sprintf('LTSA read byteloc %d failed, file size = %d bytes', ...
        skip, finfo.bytes);
    disp_msg(msg_str);
end

pwr = fread(fid,[REMORA.ship_dt.ltsa.nf,nbin],'int8');   % read data