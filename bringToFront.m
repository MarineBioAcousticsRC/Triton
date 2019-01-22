function bringToFront(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% bringToFront.m
%
% easy function for bring windows to the front
% Parameters:
%   varargin - list of windows to bring to the front. If empty, will bring all
%              triton windows to the front
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS handles
if isempty(varargin)%bring all to front
    x = findobj('type','figure','Visible','on');
    for y=1:length(x)
        figure(x(y));
    end
else
    for x = 1:length(varargin)
        figure(findobj('type', 'figure', 'Name', varargin{x}));
    end
end