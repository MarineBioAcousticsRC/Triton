function read_ltsadata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% read_ltsadata.m
%
% reads the ltsa data portion of the file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS

check_ltsa_time

ltsaFullFile = fullfile(PARAMS.ltsa.inpath, PARAMS.ltsa.infile);

fid = fopen(ltsaFullFile,'r');

nbin = floor((PARAMS.ltsa.tseg.hr * 60 *60 ) / PARAMS.ltsa.tave); 

% which raw file to start plot with
PARAMS.ltsa.plotStartRawIndex = [];
% find which raw file plot start time (PARAMS.ltsa.plot.dnum) is in
% 
PARAMS.ltsa.plotStartRawIndex = find(PARAMS.ltsa.plot.dnum >= PARAMS.ltsa.dnumStart ...
     & PARAMS.ltsa.plot.dnum + datenum([0 0 0 0 0 PARAMS.ltsa.tave])  <= PARAMS.ltsa.dnumEnd, 1);
 %
% if the plot start time is not within a raw file (i.e., non-recording time between raw files),
% find which ones it is between 
%
if isempty(PARAMS.ltsa.plotStartRawIndex)
    PARAMS.ltsa.plotStartRawIndex = min(find(PARAMS.ltsa.plot.dnum <= PARAMS.ltsa.dnumStart));
    PARAMS.ltsa.plot.dnum = PARAMS.ltsa.dnumStart(PARAMS.ltsa.plotStartRawIndex);
end

%
% time bin number at start of plot within rawfile (index)
PARAMS.ltsa.plotStartBin = floor((PARAMS.ltsa.plot.dnum - ....
    PARAMS.ltsa.dnumStart(PARAMS.ltsa.plotStartRawIndex)) * 24 * 60 * 60 ...
    / PARAMS.ltsa.tave) + 1;

% samples to skip over in ltsa file
skip = PARAMS.ltsa.byteloc(PARAMS.ltsa.plotStartRawIndex) + ....
    (PARAMS.ltsa.plotStartBin - 1) * PARAMS.ltsa.nf;

status = fseek(fid,skip,-1);    % skip over header + other data
if status == -1
    % The seek failed, which means the requested block is past the end of the
    % file -- an LTSA whose generation was interrupted, so the header promises
    % more spectra than were ever written. Reading on regardless would return
    % whatever the file pointer happened to be sitting on, and those values
    % look like real spectra from the wrong time. Return NaN instead so the
    % gap is visible rather than plausible.
    finfo = dir(ltsaFullFile);
    msg_str = sprintf('LTSA read byteloc %d failed, file size = %d bytes', ...
        skip, finfo.bytes);
    disp_msg(msg_str);
    disp_msg('LTSA is shorter than its header declares - showing no data for this window');
    fclose(fid);
    PARAMS.ltsa.pwr = nan(PARAMS.ltsa.nf,nbin);
    tbinsz = PARAMS.ltsa.tave/(60*60);
    PARAMS.ltsa.t = [0.5*tbinsz:tbinsz:(nbin-0.5)*tbinsz];
    PARAMS.ltsa.f = PARAMS.ltsa.freq;
    return
end
PARAMS.ltsa.pwr = [];
PARAMS.ltsa.pwr = fread(fid,[PARAMS.ltsa.nf,nbin],'int8');   % read data

% time bins
tbinsz = PARAMS.ltsa.tave/(60*60);
% only good for continuous data, but just used for seconds/pixel in ltsa
% plot
PARAMS.ltsa.t = [];
PARAMS.ltsa.t = [0.5*tbinsz:tbinsz:(nbin-0.5)*tbinsz];

fclose(fid);

