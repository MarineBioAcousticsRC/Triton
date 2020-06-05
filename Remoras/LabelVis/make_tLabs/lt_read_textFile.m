function [Starts, Stops, Labels] = lt_read_textFile(Filename, varargin)
% [Start, Stop, Labels] = ioReadLabelFile(Filename, Optional arguments)
% Return the start & stop times as well as the associated labels
% from a Wavesurfer/HTK label file.  
% 
% Optional arguments
%  'LabelTranslation', {Match, Replace} - Regular expression to match and
%       replace labels.  Consecutive click regions are only grouped into
%       similar tokens if they contain the same label.  As some labels
%       may contain call specific information, this provides a method
%       to extract information relevant to the class being decided.  As
%       an example, the label 'Dc-SC-32.8' may mean Delphis capensis
%       recorded in Southern California with an SNR of 32.8 (application
%       specific example).  By providing a match string of:
%               '(?<species>[^-]+)-?(?<location>[^-]+)?-?(?<snr>[^-]+)?'
%       and a replace string of:  '$<species>',
%       the label would be mapped to 'Dc' which would make all similarly
%       labeled calls be marked as having been produced by Dephis
%       capensis.  By default, no label translation is done.  Labels that
%       do not match the regular expression are not modified.
%  'LabelFilter', string - Only process clicks whose label matches string.
%       Filtering is applied after LabelTranslation.
%  'Binary', true|false - Start/stop times of file have been saved in binary
%       format.
%
% Do not modify the following line, maintained by CVS
% $Id: ioReadLabelFile.m,v 1.6 2007/09/25 19:47:42 mroch Exp $

error(nargchk(1,Inf,nargin))

LabelFilter = [];       % defaults for optional args
LabelMatch = [];
LabelReplace = [];
binary = false;

vidx=1;
while vidx <= length(varargin)
  switch varargin{vidx}
   case 'LabelTranslation'
    if iscell(varargin{vidx+1}) && length(varargin{vidx+1}) == 2
      LabelMatch = varargin{vidx+1}{1};
      LabelReplace = varargin{vidx+1}{2};
    end
    if ~ ischar(LabelMatch) || ~ ischar(LabelReplace)
      error(['LabelTranslation requires a cell array:  ' ...
             '''MatchRegExp'', ''ReplaceExp''']);
    end
    vidx = vidx + 2;
   case 'LabelFilter'
    LabelFilter = varargin{vidx+1};
    if ~ischar(LabelFilter)
      error('LabelFilter requires a character argument');
    end
    vidx= vidx + 2;
   case 'Binary'
    binary = varargin{vidx+1};
    vidx = vidx + 2;
   otherwise
    error('Optional argument %s not recognized', varargin{vidx});
  end
end

Starts = [];
Stops = [];
Labels = {};

1;

linefeed = sprintf('\n');
fileh = fopen(Filename, 'r', 'ieee-le');
if fileh < 1
    error('Unable to open %s', Filename);
end    

fseek(fileh, 0, 'eof');   % Find length of file
eofposn = ftell(fileh);
fseek(fileh, 0, 'bof');

% Loop through file, reading each line
moretoread = true;
while moretoread
  if binary
    Start = fread(fileh, 1, 'double');
    Stop = fread(fileh, 1, 'double');
  else
    Start = fscanf(fileh, '%f', 1);
    Stop = fscanf(fileh, '%f ', 1);
  end
  if ~ isempty(Start) && ~ isempty(Stop)
    Starts(end+1) = Start;
    Stops(end+1) = Stop;

    % Read to end of line
    % The following would have been more simple, but fgets/fgetl have problems
    % when the \n is followed by \r.  Even in binary mode, it reads both
    % characters.  Very bad if the next start time has a first byte of 0xd
    % ('\r').  Labels{end+1} = fgetl(fileh);
    chars = '';
    nextchar = char(fread(fileh, 1, 'char'));
    while nextchar ~= linefeed && ~ isempty(nextchar)
      chars(end+1) = nextchar;
      nextchar = fread(fileh, 1, 'char');
    end
    Labels{end+1} = chars;
  end
  
  moretoread = eofposn ~= ftell(fileh);
  
end

if fclose(fileh) == -1
  error('Unable to close %s', Filename)
end

% First match/replace
if ~ isempty(LabelMatch)
  Labels = regexprep(Labels, LabelMatch, LabelReplace);
end


if ~ isempty(LabelFilter)
    % Loop through labels in reverse order, deleting anything
    % that does not match
    for idx=length(Labels):-1:1
        if isempty(strfind(Labels{idx},LabelFilter))
            Start(idx) = [];
            Stop(idx) = [];
            Labels(idx) = [];
        end
    end
end

% Change to column vectors
Starts = Starts';
Stops = Stops';
Labels = Labels';
