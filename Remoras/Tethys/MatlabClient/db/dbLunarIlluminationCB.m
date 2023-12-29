function dbLunarIlluminationCB(hObject, eventdata, handles)
% visPrecenceCB(hObject, eventdata, handles)
% callback for visPresence, should not be invoked by user

% retrieve dates
info = get(hObject, 'UserData');
% Convert x/y to serial date
start = hObject.XData(1) + hObject.YData(1);
fprintf('Lunar Illumination Percent: %f at %s\n', ...
    info.illu, datestr(start, 'yyyy-mm-dd hh:MM'));


