function params = ioLoadLTSAParams(filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% params = ioLoadLTSAParams(filename)
% Read in LTSA detection parameters
% Returns empty matrix on failure.
% Do not modify the following line, maintained by CVS
% $Id: ioLoadLTSAParams.m,v 1.1 2007/05/01 20:21:08 mroch Exp $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hFile = fopen(filename, 'r');
if hFile == -1
  params = [];  % Unable to open file
else
  nparam = str2double(fgets(hFile));  % Read number of parameters
  if nparam < 1
    params = [] % Bad parameters;
  else

    % Assume that user wants detection enabled (as they bothered to load this)
    params.Enabled = true;

    % done this way because Matlab compiler doesn't allow eval per load params
    params.paramfile = filename;
    params.ignore_periodic = str2num(fgetl(hFile));
    params.LowPeriod_s = str2num(fgetl(hFile));
    params.HighPeriod_s = str2num(fgetl(hFile));
    params.HzRange = str2num(fgetl(hFile));
    %params.MinDuration = str2num(fgetl(hFile));
    params.Threshold_dB = str2num(fgetl(hFile));
    params.mean_enabled = str2num(fgetl(hFile));
    if params.mean_enabled
      params.pwr_mean = str2num(fgetl(hFile));
    end
    params.MeanAve_hr = str2num(fgetl(hFile));
    params.ifPlot = str2num(fgetl(hFile));

    fclose(hFile);
  end
end


