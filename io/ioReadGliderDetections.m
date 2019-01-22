function [timestamps, scores, labels] = ioReadGliderDetections(filename, triton_timestamp)
% tlabels = ioReadGliderDetections(filename)
% Read in detections from SDSU/SIO HARP classifier module

if nargin < 2
    triton_timestamp = true;
end

[date, time, offsets_s, scores, labels] = ...
    textread(filename, '%s %s %f %f %s');

% Convert date and time to Triton date -----------------------
% concatenate the day and hour
timestr= cellfun(@(d, h) sprintf('%s %s', d, h), date, time, ...
    'UniformOutput', false);
% convert to serial date & time offset into block
offsets_ser = datenum(0, 0, 0, 0, 0, offsets_s);  % convert s to datenum
timestamps = datenum(timestr, 'mm/dd/yy HH:MM:SS.FFF') + offsets_ser;

if triton_timestamp
    timestamps = timestamps - dateoffset();
end

