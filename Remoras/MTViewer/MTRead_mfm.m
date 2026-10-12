function [p,header,infor] = MTRead_mfm(filename,start,len,slMode)
% function [data,HEADER,INFOR] = MTRead(FILENAME,START,LENGTH,'P')
% Reads a file that is in MT format.
%
%  INPUTS:
%           FILENAME	   the name of file (as a string variable) to read.
%           START          the number of seconds into the file to begin reading.
%                            (Default = beginning of file)
%           LENGTH         the length of data to read (in seconds)
%                            (Default = to end of file)
%           'P' (optional) Use if START and LENGTH are input using number of
%                            sample points rather than seconds.  When not
%                            present, time input (seconds) are assumed.
%
% OUTPUTS:
%           data           vector containing the data read from the file in 
%                            mPa (1e-3Pa) units.
%           HEADER         Structure variable containing the header information 
%                            (string values) from the MT file.  Information is
%                            primarily engineering values
%           INFOR           Structure variable containing data relavent
%                            information
%           INFOR.filename    Name of file
%           INFOR.filesize    Total size of file, in bytes
%           INFOR.when        Date/Time in MATLAB 6-element form
%           INFOR.datenumber  Date/Time in MatLab datenumber format
%           INFOR.whenC       Date/Time in C time_t form
%           INFOR.srate       Sample Rate in Hz
%           INFOR.nsamp       Number of sample points in file
%           INFOR.seconds     Number of seconds in file
%           INFOR.count       Number of sample points actually read and
%                            returned in data
%
%  Note that the time reported in HEADER is at the beginning
%  of the file, but that the time reported in INFOR.when and
%  INFOR.whenC are at the beginning of data read; in other
%  words, the time at the start of the file, plus START seconds.

%  MODIFICATION HISTORY:
%
%  8/18/03 WCB Original Bob Blaylock internal code patched
%  to work properly with strings that may have garbage after
%  the null terminator.
%
%  4/11/04 WCB Renamed to MTRead(), all necessary functions
%  incorporated into a single file, removed Blaylock comments
%  warning about "obsolete" header data -- these only apply
%  to the BGB extensions to MT format that the Bioacoustic
%  Probe does not use.  The necessary functions that had to
%  be appended to this file were:  c2mat_tm.m, mat2c_tm.m,
%  contains.m, limits.m, and strtrim.m.
%
%  4/14/04 WCB Added check for malformed wordsize entry in the
%  MT header; assumes 2 bytes per sample if the original value
%  is not properly formed.
%
%  9/17/09 CWM changed infor.when assignment to correct an assignment error,
%  added infor.datenumber time entry
if nargin < 4
    slMode = 's';
    if nargin < 3
        len = inf;
        if nargin == 1
            start = 0;
        end
    end
end
% testing: filename = [inpath '/' D(ii).name];
[f,msg] = fopen(filename,'r','b');
if f < 1
   fclose all;
   error([10 '  Sorry about this...' 10 '    But I can''t open this file.' 10 '      I get this error:' 10 10 '  "' filename '":  ' msg 10 10]);
end
header.magicstring = MakeString(fread(f,8,'char'));

if ~strcmp(header.magicstring,'DATA')
   fclose all;
   error([10 '  This is the wrong file!' 10 '    It''s not MT format.' 10 '      I can do nothing!' 10 10 '  Trying to read "' filename '"' 10]);
end
header.totalhdrs       = MakeString(fread(f, 3,'char'));
header.abbrev          = MakeString(fread(f, 8,'char'));
header.stationcode     = MakeString(fread(f, 3,'char'));
header.title           = MakeString(fread(f,82,'char'));
header.month           = MakeString(fread(f, 3,'char'));
header.day             = MakeString(fread(f, 3,'char'));
header.year            = MakeString(fread(f, 5,'char'));
header.hours           = MakeString(fread(f, 3,'char'));
header.minutes         = MakeString(fread(f, 3,'char'));
header.seconds         = MakeString(fread(f, 3,'char'));
header.msec            = MakeString(fread(f, 4,'char'));
header.sampling_period = MakeString(fread(f,15,'char'));
header.samplebits      = MakeString(fread(f, 3,'char'));
header.wordsize        = MakeString(fread(f, 2,'char'));
if str2num(header.wordsize) < (str2num(header.samplebits)/8)
    warning(['  (Loading file "' filename '")' newl newl '  The samplebits field...' newl '    Does not fit the wordsize field.' newl '      This file may be bad. ' newl]);
end

header.typemark        = MakeString(fread(f, 1,'char'));
header.swapping        = MakeString(fread(f, 1,'char'));
header.signing         = MakeString(fread(f, 1,'char'));
header.caltype         = MakeString(fread(f, 1,'char'));
header.calmin          = MakeString(fread(f,15,'char'));
header.calmax          = MakeString(fread(f,15,'char'));
header.calunits        = MakeString(fread(f,40,'char'));
header.recordsize      = MakeString(fread(f, 6,'char'));
header.sourcevers      = MakeString(fread(f, 9,'char'));
fseek(f,0,'eof');
infor.filename = filename;
infor.filesize = ftell(f);
fclose(f);
infor.srate = 1/str2num(header.sampling_period);
infor.when = [str2num(header.year) str2num(header.month) str2num(header.day) str2num(header.hours) str2num(header.minutes) str2num(header.seconds)+str2num(header.msec)/1000];
infor.datenumber = datenum([header.year,'/',header.month,'/',header.day,' ',header.hours,':',header.minutes,':',header.seconds,'.',header.msec],'yyyy/mm/dd HH:MM:SS.FFF');
if upper(slMode) == 'P',      % Start & Length specified in # Points (samples)
     infor.whenC = mat2c_tm(infor.when) + start/infor.srate;
     infor.datenumber = infor.datenumber + start/infor.srate/24/3600;
else
     infor.whenC = mat2c_tm(infor.when) + start;        % Corrected start time (with offset)
     infor.datenumber = infor.datenumber + start/24/3600;
end
infor.when = c2mat_tm(infor.whenC);
%
% Some MT files have corrupted wordsize (no null terminator) -- if so
% assume 2-byte words
%
if (isempty(header.wordsize))
 	header.wordsize = '2';
end
infor.nsamp = (infor.filesize - 512*str2num(header.totalhdrs))/str2num(header.wordsize);
infor.seconds = infor.nsamp/infor.srate;
if len > 0  %  Only load data if it's been asked for.
    if any(contains(header.swapping,'SLsl'))
        mode = 'ieee-le';
    else
        mode = 'ieee-be';
    end
    [f,msg] = fopen(filename,'rb',mode);
    if f < 1
        fclose all;
        error([10 '  Sorry about this...' 10 '    But I can''t open this file.' 10 '      I get this error:' 10 10 '  "' filename '":  ' msg 10 10]);
    end
    if upper(slMode) == 'P',    % specified start time in sample 'P'oints rather than time
        status = fseek(f,round(512*str2num(header.totalhdrs) + round(start)*str2num(header.wordsize)),'bof');  % Skip by samples/points
    else
        status = fseek(f,round(512*str2num(header.totalhdrs) + round(start*infor.srate)*str2num(header.wordsize)),'bof');   % skip by time (seconds)
    end
    if status == 0  %% If status is nonzero, we probably went past the end of the file.
        if any(header.caltype == 'fF')
            if ~any(str2num(header.wordsize) == [4,8])
                fclose(f);
                error([10 '  Invalid word size!' 10 '    Only valid Float sizes...' 10 '      Are four or eight bytes.' 10 10]);
            end
            binType = ['float' num2str(str2num(header.wordsize)*8)];
        else
            binType = ['bit' num2str(str2num(header.wordsize)*8)];
            if any(contains(header.signing,'Uu'))
                binType = ['u' binType];
            end
        end
        if upper(slMode) == 'P'
            [p,infor.count] = fread(f,len,binType);
        else
            [p,infor.count] = fread(f,round(len*infor.srate),binType);
        end
        fclose(f);
        calmax = str2num(header.calmax);
        calmin = str2num(header.calmin);
        if (length(calmin) == 1) && (length(calmax) == 1) && ((calmin + eps) < calmax) && ~any(header.caltype == 'fF')
            calmax = str2num(header.calmax);
            calmin = str2num(header.calmin);
            if any(contains(header.signing,'Uu'))
                bitmin = 0;
                bitmax = (2^str2num(header.samplebits)) - 1;
            else
                bitmin = -(2^(str2num(header.samplebits)-1));
                bitmax = (2^(str2num(header.samplebits)-1)) - 1;
            end
            multiplier = (calmax-calmin)/(bitmax-bitmin);
            p = (p - bitmin).*multiplier + calmin;
        end
    else
        p = [];    % Output an empty matrix if requested data is beyond the length of the current file
    end
else
    p = [];      % Also output an empty matrix of zero length LENGTH input is requested (ie, only return header/infor values)
    infor.count = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = MakeString(s)
% The standard is that the string is null-terminated,
% so we know there will be a null somewhere.  Make the
% string out of everything up to the null.
%
% The standard also says that the rest of a field should
% be nulled, but in case it wasn't and there is garbage
% after the terminating null, this will ignore the garbage.
%
% Note if the length of s is exactly 1 we just leave it
% alone.  Only if it's longer than one do we look for
% the null terminator.
 s = char(s(:)');
 if (length(s) > 1)		% Multi-char string?
 	xx = find(s==0);	% Yes, look for null terminator
 	if (~isempty(xx))	% Null terminator exists
 		if (xx(1) > 1)	% Is it not the first character?
 			s = strtrim(s(1:(xx(1)-1)));
 		else
 			s = ''; 	% Multi-char string but first character was a null!
 		end
 	else
 		s = '';			% Multi-char string but no null terminator found!
 	end
 else					% Single-char string
 	if (s(1) == 0)		% But is that single char a null?
 		s = '';			% If so, this is a null string
 	end
 end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = strtrim(s)
%  function s = strtrim(s)
%
%  Trims blanks and nulls from both ends of the string.
  if ~isempty(s)
   xx = limits(find((~isspace(s))&(s~=0)));
    if isempty(xx)
     s = '';
    else
     s = s(xx(1):xx(2));
    end
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function l=limits(x)
%  Returns a two-element vector containing the lowest and highest values
%  found in all elements of the input array.
 l = [min(x(:)) max(x(:))];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tm = c2mat_tm(tc,fs)
% tm = c2mat_tm(tc)
%  Where tc is a scalar containing a date/time as stored by C, as the
%  number of seconds past Midnight, January 1, 1970, this function will
%  return in tm a six-element row vector containing the same date/time
%  in MATLAB's format.
%
%
% tm = c2mat_tm(tc,fs)
%
%  The additional argument, fs, will be added to the seconds field of the
%  result.  This is to allow times to be specifed to fractions of a second.
%  If no second input argument is given, then the fractional part of tc, if
%  present, will be used.
a = version;
 if (a(1) == 4) && (a(2) == '.')
  error('Missing c2mat_tm.mex');
 else
   if nargin > 2
    tc = tc + fs;
   end
  tm = datevec((tc+6.216730560000000e+010)/(24*60*60));
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tc,fs] = mat2c_tm(tm)
% tc = mat2c_tm(tm)
%
%  Where tm is a 6-element row vector containing a date/time in MATLAB's
%  format, this function will return in tc a scalar containing the same
%  date/time in the standard C format, as the number of seconds past
%  Midnight, January 1, 1970.
%
%
% [tc,fs] = mat2c_tm(tm)
%
%  If the second output argument, fs, if given, then only an integer value
%  will be returned in tc, with the fractional part of the seconds in fs.
a = version;
 if (a(1) == 4) && (a(2) == '.')
  error('Missing mat2c_tm.mex');
 else
  tc = datenum(tm(1),tm(2),tm(3),tm(4),tm(5),tm(6))*(24*60*60) - 6.216730560000000e+010;
   if nargout > 1
    fs = tc - fix(tc);
    tc = fix(tc);
   end
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = contains(what,where,dummy)
% X = contains(WHAT,WHERE)
%
%  For each element of WHAT, this function returns a 1 in the corresponding
%  element of X if that element is found in WHERE, and a 0 if it is not.
%
  if nargin >= 3
   dummy = dummy*dummy;
  end

  if isempty(where)
   x = zeros(size(what));
   return;
  elseif isempty(what)
   x = [];
   return;
  end

 x = logical(zeros(size(what)));
  for ii = 1:numel(what)
   xx = any(what(ii) == where);
    if isempty(xx)
     xx = 0;
    end

    while numel(xx) > 1
     xx = any(xx(:));
    end
   x(ii) = xx;
  end