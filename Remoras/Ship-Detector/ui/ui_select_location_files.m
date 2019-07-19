function ui_select_location_files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% ui_select_location_files.m
%
% Select files and verify directories in GUI before running detector
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA

% Verify if ltsa is previously loaded
if isempty(PARAMS.ltsa.infile)
    detParams.ltsaFile = false; 
end

REMORA.dt_settings = [];

defaultPos = [0.25,0.25,0.3,0.3];
REMORA.fig.dt_settings = figure( ...
    'NumberTitle','off', ...
    'Name','Ship Detector Batch - v1.0',...
    'Units','normalized',...
    'MenuBar','none',...
    'Position',defaultPos, ...
    'Visible', 'on');

% button grid layouts
% 10 rows, 4 columns
r = 10; % rows      (extra space for separations btw sections)
c = 4;  % columns
h = 1/r;
w = 1/c;
dy = h * 0.6;
% dx = 0.008;
ybuff = h*.2;
% y position (relative units)
y = 1:-h:0;

% x position (relative units)
x = 0:w:1;

% colors
bgColor = [1 1 1];  % white
bgColorRed = [1 .6 .6];  % red
bgColorGray = [.86 .86 .86];  % gray
bgColor3 = [.75 .875 1]; % light green 
bgColor4 = [.76 .87 .78]; % light blue 

% Set paths and strings
%*************************************
labelStr = 'Select detector settings source';
btnPos=[x(1) y(2) 4*w/2 dy];
REMORA.dt_settings.headtext = uicontrol(REMORA.fig.dt_settings, ...
    'Style','text', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'String',labelStr, ...
    'FontUnits','points', ...
    'FontSize',10,...
    'FontWeight','bold',...
    'Visible','on'); 


        %'BackgroundColor',bgColorGray,...
%     'FontWeight','bold',...


