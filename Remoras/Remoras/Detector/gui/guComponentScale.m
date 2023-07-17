function handles = guComponentScale(hObject, eventdata, handles)
% guComponentScale(hObject, eventdata, handles) 
%
% Given a figure of reusable components that has been created using
% guComponentLoad, rescale the components such that they are all visible.

if handles.MinimumY < 0
  Vertical = 1 - handles.MinimumY;      % total vertical distance
  Scale = 1/Vertical;
  
  hChildren = get(hObject, 'Children');
  PositionY = 2;
  Height = 4;
  % This has not been tested on components with units to anything other
  % than normalized.  It should work, for anything, but it has only
  % been tested with normalized units.
  for idx=1:length(hChildren)
    units = get(hChildren(idx), 'Units');
    normalize = ~ strcmp(units, 'normalized');
    if normalize
        set(hChildren(idx), 'Units', 'normalized');
    end
    Position = get(hChildren(idx), 'Position');
    % Translate Y position up so everyting is in interval
    % [0, 1+abs(handles.MinimumY)].
    Position(PositionY) = (Position(PositionY) - handles.MinimumY) * Scale;
    Position(Height) = Position(Height) * Scale;
    set(hChildren(idx), 'Position', Position);
    if normalize
        % Restore to previous units
        set(hChildren(idx), 'Units', units);
    end
  end
  handles.MinimumY = 0.0;
end
    
