function visPresenceCB(hObject, eventdata, handles)
% visPrecenceCB(hObject, eventdata, handles)
% callback for visPresence, should not be invoked by user

% retrieve dates
info = get(hObject, 'UserData');
label = '';
if ~isempty(info.label)
    label = sprintf('%s%s: ', label, info.label);
end
label = sprintf('%s%s to %s', label, datestr(info.dates(1), 0), ...
    datestr(info.dates(2), 0));

fprintf('%s\n', label);   % write to matlab

% get bounding box and put temporary message
vertices = get(hObject, 'Vertices');
center = mean(vertices);
if center(1) < .2   % to do, make relative to currently visible area rather than entire plot
    position = 'left';
else if center(1) < .8
        position = 'center';
    else
        position = 'right';
    end
end
text_h = text(center(1), center(2)+2, label, ...
    'HorizontalAlignment', position);

% flash the region so the user knows that it has been selected
color = get(hObject, 'FaceColor');
colors = jet(20);
for k=1:size(colors, 1)
    set(hObject, 'FaceColor', colors(k,:));
    pause(.1);
end

delete(text_h);
debug = false;
if debug
    fprintf('Showing y values of callback\n');
    datestr(get(hObject, 'YData'))
end

set(hObject, 'FaceColor', color);



