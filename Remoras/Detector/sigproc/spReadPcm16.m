function Pcm = spReadPcm16(File)
% Pcm = spReadPcm16(File)
%
% Read 16 bit pulse code modulated data. It is assumed that the 
% file contains a sequence of 16 bit integers in native-byte order.
% Pcm should be a set of signed integer values in the 16 bit range.
% No conversion to Matlab's normalized [-1, 1] is done.
%
% This code is copyrighted 2003 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

FileH = fopen(File, 'r');

if FileH == -1
  error(sprintf('Unable to open %s for reading', File))
end

Pcm = fread(FileH, 'integer*2');	% read 16 bit ints

fclose(FileH);
