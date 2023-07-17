function String = sectohhmmss(Secs)
% String = sectohhmmss(Seconds)
% Converts time to a string of the the format 'hh:mm:ss'

Hours = floor(Secs/3600);
Secs = Secs - Hours*3600;
Minutes = floor(Secs/60);
Secs = Secs - Minutes*60;
Seconds = floor(Secs);

String = sprintf('%02d:%02d:%02d', Hours, Minutes, Seconds);
