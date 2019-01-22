function guErrorBacktrace(err, title, summary)
% guErrorBackTrace(err, title, summary)
% Create an erorr dialog with a stack backtrace included therein.
% The optional title and summary provide a dialog title and one
% line human readable summary.

if nargin < 3
  summary = [];
elseif nargin < 2
  title = 'Error';
end
if ~ isempty(summary)
  Msg = summary;
else
  Msg = '';
end
Msg = sprintf('%s\nError:  %s\n', Msg, err.message);
Msg = sprintf('%s\nBacktrace (most recent frame first):\n', Msg);

for frame=1:length(err.stack)
  Msg = sprintf('%s\n%s@%d\n', Msg, err.stack(frame).name, ...
                err.stack(frame).line);
end
Msg
errordlg(Msg, title);
  
