function ioWriteLabel(LabelFileName, times, label, varargin)
% ioWriteLabel(LabelFileName, times, label, OptionalArgs)
% Write a Wavesurfer format label file to file LabelFileName
%
% times is a 2 or 3 column matrix:
%       column  contents
%       1       start time s
%       2       end time s
%       3       extra information (e.g. SNR in dB)
% When the 3rd column is present, each label will have a "-" and the 
% value of the column 3 entry appended, e.g. 'click-20.2'.
%
% label indicates what label will be given to the events and may be
% one of the following:
%       string - Same label is written for all events.
%       cell array of strings - Event times(idx,:) is given label{idx}
%
% Optional arguments:
%
% 'Binary', true|false - indicates whether or not time times should be
%       written in a binary format.  This is useful for avoiding rounding
%       errors when times are displayed as text, but note that this deviates
%       from the Wavesurfer label format.
%  
% Do not modify the following line, maintained by CVS
% $Id: ioWriteLabel.m,v 1.7 2010/08/23 18:59:35 mroch Exp $

binary = false;         % defaults

vidx=1; % parse optional arguments
while vidx <= length(varargin)
    switch varargin{vidx}
        case 'Binary'
            binary = varargin{vidx+1};
            vidx = vidx+2;
        otherwise
            error('Bad optional argument');
    end
end

handle = fopen(LabelFileName, 'w', 'ieee-le');

[LabelCount, Fields] = size(times);

if ~ iscell(label)
  EventLabel = label;   % Same label for all events
end

for n = 1:LabelCount
  if iscell(label)
    EventLabel = label{n};      % label for this event
  end
  ioWriteLabelEntry(handle, times(n,:), EventLabel, binary);
end
fprintf('Classification complete, writing label file\n');
if fclose(handle) == -1
  error('Unable to close file %s', LabelFileName)
end

 
 
