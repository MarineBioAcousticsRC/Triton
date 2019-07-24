function [rawIndex, tBin, present] = fn_ltsa_TimeIndexBin(time)
% [rawIndex, tBin] = fn_ltsa_TimeIndexBin(time)
%
% Given a Matlab serial date (dnum), find the raw index file and LTSA bin
% that contains it.  The variable present is true when a long term spectral
% average was calculated for the requested time, and false when it is
% between valid times, such as when the data has been scheduled (duty
% cycled) and the requested time is when the sensor is inactive.
%
% Do not modify the following line, maintained by CVS
% $Id: ltsa_TimeIndexBin.m,v 1.2 2007/11/30 00:17:01 mroch Exp $

% Based upon functionality in read_ltsadata.
% Replace read_ltsadata code with this function once it has been proven
% to avoid maintaining duplicate code.

global PARAMS

rawIndex = find(time >= PARAMS.ltsa.dnumStart & ...
                time <= PARAMS.ltsa.dnumEnd);

if isempty(rawIndex)
  % first one past requested time
  rawIndex = min(find(time < PARAMS.ltsa.dnumStart));
  present = false;
else
  present = true;
  if ~ isscalar(rawIndex)
    % Under most circumstances, any given instant in time should  
    % occur only in one file.
    multtimewarn = true;        % if too annoying set to false
    if multtimewarn 
      files = sprintf('%s ', PARAMS.ltsahd.fname{rawIndex});
      warning('Requested time %s occurs in multiple files %s.', ...
              files, datestr(time));
    end
    rawIndex = rawIndex(1);  
  end
end

% Find ltsa bin number in current rawIndex
if present
  delta = time - PARAMS.ltsa.dnumStart(rawIndex);
  % Compute bin width 
  tBinWidth = datenum([0 0 PARAMS.ltsa.tave/(60*60*24)]);
  tBin = 1 + round(delta / tBinWidth);
else
  tBin = 1;
end


