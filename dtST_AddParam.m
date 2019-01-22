function [args, WhistlePos, ClickPos] = dtST_AddParam
% [args, WhistlePos, ClickPos] = dtST_AddParam
%
% Creates cell array of arguments for dtST_signal if saved parameters have 
% been loaded and outputs whistle and click positions
%
% 060917 mss
%
% Do not modify the following line, maintained by CVS
% $Id: dtST_AddParam.m,v 1.1.1.1 2006/09/23 22:31:58 msoldevilla Exp $

global PARAMS

WhistlePos = PARAMS.dt.WhistlePos;
ClickPos = PARAMS.dt.ClickPos;

args = {'MeanAve_s', PARAMS.dt.MeanAve_s, ...
    'WhistlePos', PARAMS.dt.WhistlePos, ...
    'ClickPos', PARAMS.dt.ClickPos, ...
    'Ranges', PARAMS.dt.Ranges, ...
    'Thresholds', PARAMS.dt.Thresholds};

if WhistlePos
  args = [args, {'WhistleMinLength_s', PARAMS.dt.WhistleMinLength_s, ...
      'WhistleMinSep_s', PARAMS.dt.WhistleMinSep_s}];
end
if ClickPos
    args = [args,  {'MinClickBandwidth', PARAMS.dt.MinClickBandwidth}];
end
 

