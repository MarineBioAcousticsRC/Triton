function Dates = dateregexp(Strings, RE, DefaultDate, OffsetFrom)
% dates = dateregexp(Strings, Regexp, DefaultDate, OffsetFrom)
%
% Given a set of Strings and regular expressions RE specifying the date
% format, return a vector of serial time formats (see datenum).  Strings
% and RE may either be a character vector or a cell array where each
% element is a character vector.
%
% Optional DefaultDate is a datenum that is used for strings that are not
% matched by RE and defaults to the serial date corresponding to 1-Jan-0000
% 00:00:00.
% Optional OffsetFrom is a serial date number which will be
% subtracted from all dates that match a regular expression.
%
% The regular expressions should contain the following named patterns (see
% Matlab help on regular expressions for help on regular expressions and
% and named patterns):
%
%       yr, mon, day, hr, min, s, ampm.
%
% For the ampm field, we expect a case insenstive form of AM or PM.  
% A.M. and P.M. are not accepted.
%
% Hours, minutes and seconds are optional in Regexp and can be omitted from
% the pattern.  In addition, it is possible to also capture specify
% recognition of an offset to the date by optionally specifying the same
% patterns prepended by a d:
%
%       dyr, dmon, dday, dhr, dmin, ds
%
% Example:
% If Regexp{1} were set to:
% '(?<mon>\d\d)(?<day>\d\d)(?<yr>\d\d)-(H\d+-)?(?<hr>\d\d)(?<min>\d\d).*_(?<dmin>\d\d)(?<ds>\d\d)-'
% and Strings{1} contained
% Set4-A5-092705-H57-0600-0618-1435-1453loc_filter_1200-1400mi.wav
%         ^^^^^^     ^^^^                          ^^^^
% then dates(1) would contain the number corresponding to 
% 27-Sep-2005 06:12:00.  This corresponds to the 27-Sep-2005 06:00:00
% date specified in the first part of the filename and the offset of 12 m
% and zero s specified in the latter part.
%
% When multiple regular expressions are specified, they are tried in
% order.  The first one to create a match is used.
%
% Caveats:  Note that the optional components of the date and offset are
% optional in the *regular expression*.  If the are present in Regexp,
% they *must* be present in the date strings.

error(nargchk(2,4,nargin));

if nargin < 4
  OffsetFrom = [];
  if nargin < 3
    DefaultDate = datenum([0 1 1 0 0 0]);      % 1-Jan-0000 00:00:00
  end
end

if ischar(RE)
  tmp = RE;
  RE = cell(1);
  RE{1} = tmp;   % make everything a cell array
end

if ischar(Strings)
  tmp = Strings;
  Strings = cell(1);
  Strings{1} = tmp;   % make everything a cell array
end

StringsN = length(Strings);
Dates = zeros(StringsN, 1);

% Attempt to parse dates with specified regular expression
for idx=1:StringsN
  match = [];
  reidx = 1;
  while isempty(match) && reidx <= length(RE)
    match = regexp(Strings{idx}, RE{reidx}, 'names');
    reidx = reidx + 1;
  end
  if isempty(match)
    Dates(idx) = DefaultDate;
  else
    if length(match.yr) == 2
      match.yr = sprintf('20%s', match.yr);   % 07 --> 2007
    end
    optional = {'hr', 'min', 's'};
    for tidx = 1:length(optional)
      if ~ isfield(match, optional{tidx})    % s is optional
        match.(optional{tidx}) = '00';  % default when not present
      end
    end
    %match.yr = sprintf('%02d', sscanf(match.yr, '%d') - 2000);     %Sean
    %subtracts 2000 in timenum - do we need this?
    
    m = sscanf(match.mon, '%d');           %check for text/numeric month
    if m
        % numeric - 01/02/...
        months = {'jan', 'feb', 'mar', 'apr', 'may', 'jun', ...
            'jul', 'aug', 'sep', 'oct', 'nov', 'dec'};
        % If the month field is valid, the next line is not needed,
        % but include just to ensure always between 1-12 in case
        % user violates formatting.
        m = max(1, min(m, length(months)));
        match.mon = months{m};
    end
    % Check for meridian
    if isfield(match, 'ampm')
        if strcmpi(match.ampm, 'pm')
            match.hr = sprintf('%d', str2double(match.hr) + 12);
        end
    end
    % text - jan/feb/mar/...
    Dates(idx) = datenum( ...
        sprintf('%s %s, %s %s:%s:%s', ...
        match.mon, match.day, match.yr, match.hr, match.min, match.s), 0);

    
    % Create an offsets date vector and populate all fields that
    % are present.  Note that this is for offsets encoded in the
    % filename, not the OffsetFrom parameter.
    offsetvec = datevec(0);
    offsetFields = {'dyr', 'dmon', 'dday', 'dhr', 'dmin', 'ds'};
    for tidx = 1:length(offsetFields)
      if isfield(match, offsetFields{tidx}) & ~isempty(match.(offsetFields{tidx}))
        offsetvec(tidx) = str2double(match.(offsetFields{tidx}));
      end
    end
    offsetnum = datenum(offsetvec);   % convert to serial date
    Dates(idx) = Dates(idx) + offsetnum;  % Add offset to date
    
  end
end

% If user wants all dates offset from a specific date, subtract
% it out.
if ~ isempty(OffsetFrom)
  Dates = Dates - OffsetFrom;
end
