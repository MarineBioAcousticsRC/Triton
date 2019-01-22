function spWritePcm16(File, Pcm)
% spWritePcm16(File, Pcm)
%
% Write Pcm to a file.
% Pcm should be a set of signed integer values in the 16 bit range.
% No conversion from Matlab's normalized [-1, 1] is done.
%
% This code is copyrighted 2003 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

FileH = fopen(File, 'w');

if FileH == -1
  error(sprintf('Unable to open %s for writing', File))
end

fwrite(FileH, Pcm, 'integer*2');	% write as 16 bit ints

fclose(FileH);
