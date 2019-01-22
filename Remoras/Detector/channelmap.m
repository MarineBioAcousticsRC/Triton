function channel = channelmap(hdr, filename)
% channel = channelmap(hdr, filename)
% Given a file header and filename, select the channel to process
% according to user criteria.  
%
% Currently, channel selection is hard coded and this file
% must be edited.  The eventual goal is to have a GUI
% which lets you select critiera such as experiment name, date
% ranges, etc.


Map = { 
    % {NumCh, UseCh, StrToMatchFilename
    {8, 7, 'FLIP0610'},
    {4, 3, 'FLIP0610'},
    {2, 2, 'SCI0704'},
    {2, 2, '21apr2007y'}
    {4, 2, 'JAX'}
    };
NumCh = 1;      % for indexing
UseCh = 2;
MatchStr = 3;

found = false;
idx = 1;
channel = 1;    % default
while ~ found && idx <= length(Map)
  if hdr.nch == Map{idx}{NumCh} && ...
              ~ isempty(strfind(filename, Map{idx}{MatchStr}))
    channel = Map{idx}{UseCh};
    found = true;
  else
    idx = idx + 1;
  end
end
