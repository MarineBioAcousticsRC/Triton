function DATA = get_xwav_data_1ch_fromLTSAhd( xwav, startt, endt )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DATA = get_xwav_data_1ch( xwav, startt, endt )
%  
%  Given start/end strings, returns data from single channel xwav
%   
%  xwav - xwav w/ path
%  startt - start time in datenum() friendly format, if time is before
%         start time of file, data is read in from BOF
%  endt - end time in datenum() friendly format, if time is after end time
%         of file, data is read in until EOF
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS

DATA = [];

if ~ischar(startt) || ~ischar(endt)
    disp('Input time should be date strings!')  
    disp('Try again!')
    return
end

Y2K = datenum([ 2000 0 0 0 0 0 ]);
mnum2secs = 24*60*60;

dnum0 = datenum(startt); 
dnumN = datenum(endt);


[ xpath, xfn, xext ] = fileparts(xwav);
PARAMS.infile = sprintf('%s%s',xfn,xext);
PARAMS.inpath = xpath; 

% need to initialize this stuff, rdxwavhd does not
%PARAMS.xhd = [];
%PARAMS.raw = [];
PARAMS.ftype = 2;
%rdxwavhd;


if PARAMS.ltsa.nBits == 16
    dtype = 'int16';
elseif PARAMS.ltsa.nBits== 32
    dtype = 'int32';
else
    disp('PARAMS.nBits = ')
    disp(PARAMS.nBits)
    disp('not supported')
    return
end

% a lil sanity check doesn't hurt anybody
if dnum0 < ( PARAMS.start.dnum + Y2K )
    fprintf('Start time is before XWAV start!\n')
    fprintf('Setting start time to BOF\n');
    dnum0 = PARAMS.start.dnum + Y2K;
    %return
end

if dnumN > ( PARAMS.end.dnum + Y2K )
    fprintf('End time is after XWAV end!\n')
    fprintf('Setting end time to EOF\n');
    dnumN = PARAMS.end.dnum + Y2K;
    %return
end

if dnumN < dnum0
    disp('End time before the start time!') 
    return
end

rfStarts = PARAMS.raw.dnumStart + Y2K;
rfEnds = PARAMS.raw.dnumEnd + Y2K;
rfIdx0 = find( rfStarts <= dnum0,1,'last' );
rfIdxN = find( rfEnds >= dnumN, 1,'first' );

if isempty(rfIdx0) 
        disp('Couldn''t find date range in XWAV...PANIC!');
        return; 
end

% check that start time is not in gap
if rfEnds(rfIdx0) < dnum0  
    rfIdx0 = rfIdx0+1;
    fprintf('Start time not found in data, data starts %s\n', datestr(rfStarts(rfIdx0),'mm/dd/yy HH:MM:SS.FFF'));
    skip_s = 0;    
else
   skip_s = (dnum0 - rfStarts(rfIdx0)) * mnum2secs; 
end

% check that end time is not in gap
if rfStarts(rfIdxN) > dnumN
    rfIdxN = rfIdxN-1;
    fprintf('End time not found in data, data ends %s\n', datestr(rfEnds(rfIdxN),'mm/dd/yy HH:MM:SS.FFF'));
    end_s = (rfEnds(rfIdxN)-rfStarts(rfIdxN) )*mnum2secs; 
else
    end_s = (dnumN - rfStarts(rfIdxN)) * mnum2secs;
end

% check that raw files are still ordered
if rfIdxN < rfIdx0
        disp('No data available for time period!\n');
        return; 
end
% skip_samp = ceil(skip_s * PARAMS.fs)-1;
skip_samp = round(skip_s * PARAMS.ltsa.fs);
% bytes to skip from start of file
start_B = PARAMS.xhd.byte_loc(rfIdx0) + skip_samp * floor(PARAMS.ltsa.nBits/8); 
% fprintf('skip_s = %f,\tskip_samp = %d,\tskip_B = %d\n', ...
%     skip_s, skip_samp, skip_B);


% end_samp = ceil(end_s*PARAMS.fs)-1;
end_samp = round(end_s*PARAMS.ltsa.fs);
end_B = PARAMS.xhd.byte_loc(rfIdxN) + end_samp*floor(PARAMS.ltsa.nBits/8);

%define how much data to read in
bin_B = end_B-start_B;
bin_samps = bin_B/floor(PARAMS.ltsa.nBits/8);

% fprintf('end_s = %f,\tend_samp = %d,\tend_B = %d\n\n', ...
%     end_s, end_samp, end_B);
DATA = nan(bin_samps,1);
fid = fopen(xwav,'r');
for rf=rfIdx0:rfIdxN
    % jump to raw file start
    fseek(fid, PARAMS.xhd.byte_loc(rf),'bof');
    
    if rf==rfIdx0
        % skip past data we don't want in first raw file
        b1 = skip_samp*floor(PARAMS.ltsa.nBits/8);
        fseek(fid,b1,'cof');
        
        % want to read remainder of raw file
        nb = PARAMS.xhd.byte_length(rf)-b1;
        s1 = 1; % start samp idx
    elseif rf==rfIdxN
        % only read the part we care about in last raw file
        nb = end_samp*floor(PARAMS.ltsa.nBits/8);
    else
        % read all data
        nb = PARAMS.xhd.byte_length(rf);
    end   
    
    nr = nb/floor(PARAMS.ltsa.nBits/8);
    s2 = s1+nr-1;
    DATA(s1:s2) = fread(fid, nr, dtype);
    s1 = s2+1;
end
fclose(fid);

naIdx = find(isnan(DATA),1,'first'); 
DATA(naIdx:end) = [];

if ~isempty(naIdx)
    fprintf('Not enough data read %d of %d\n', length(DATA), bin_samps);
end
