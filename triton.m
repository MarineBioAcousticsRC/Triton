function triton
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% triton.m
%
%
% Triton software package is used to display XWAV and WAV data from HARPs
% ARPs, hydrophone arrays, or other recording devices as timeseries, spectra, 
% spectrograms and LTSAs (long-term spectral averages) plots.
%
% Various tools are included to convert raw HRP format to XWAV, decimate 
% broad-band data, generate LTSAs and plots, and to add user-defined programs.
%
% A user-manual is included as a pdf file.
%
% Any feedback should be sent to 
% cetus@ucsd.edu
%
% New and archived versions of Triton are available at
% ftp://cetus.ucsd.edu/Software/
% or
% http://cetus.ucsd.edu/technologies_Software.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear global;  % clear out old globals
clc;        % clear command window  
close all force;  % close all figure windows, even hidden ones
warning off % this is turned off for plotting messages

global PARAMS

% PARAMS.ver = '1.93.20160524';
PARAMS.ver = '1.0 2025 05 13 +sfregosi/flac branch';
disp(' ')
disp(['         Triton version ', PARAMS.ver])

check_path

initparams

initwins

initcontrol

init_coorddisp

initpulldowns

