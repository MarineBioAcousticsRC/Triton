function close_figure( src, event, param )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% closeFigure.m
%
% A custom close function givin to handles that you want to hide but don't
% want to destroy the values inside.
%
% Parameters:
%   src - the window that's trying to be closed
%   event - not used but needed since it's a event handler
%   param - a string that tells whether you want to hide or delete window(src)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global HANDLES
switch param
  case 'hide'
    set(src, 'Visible', 'off');
    set(src, 'CloseRequestFcn', ... %set to delete since the next
      {@closeFigure, 'delete'}); %close call will be the actual closing of the program
  case 'delete'
    delete(src);
end
end

