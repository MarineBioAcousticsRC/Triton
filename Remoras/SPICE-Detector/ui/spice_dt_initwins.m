function spice_dt_initwins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% spice_dt_initwins.m
% 
% initialize figure, control and command(display) windows
%
% 5/5/04 smw
%
% updated 060211 - 060227 smw for triton v1.60
%
% 060517 smw - ver 1.61
%%
% Do not modify the following line, maintained by CVS
% $Id: initwins.m,v 1.4 2012/06/21 17:32:27 mroch Exp $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% figure window
%
global HANDLES PARAMS REMORA

% use screen size to change plot control window layout 
PARAMS.scrnsz = get(0,'ScreenSize');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% initialize detectors options window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% window placement & size on screen
defaultPos = [0.005,0.035,0.2,0.25];
% open and setup figure window
REMORA.fig.spice_dt = figure( ...
    'NumberTitle','off', ...
    'Name','Spice Detector Control - Remora v1.0',...
    'Units','normalized',...
    'MenuBar','none',...
    'Position',defaultPos, ...
    'Visible', 'off');
