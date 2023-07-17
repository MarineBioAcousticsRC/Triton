function [xwavNames] = sp_fn_getXWAVNames(xwavDir)
% find all files ending in ".wav" works for both x.wav and wav
d = dir(fullfile(xwavDir,'*.wav'));    % xwav files

xwavNames = char(d.name);      % file names in directory
