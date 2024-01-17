function dbLunarIlluminationCB(hObject, eventdata, handles)
% visPrecenceCB(hObject, eventdata, handles)
% callback for visPresence, should not be invoked by user

% retrieve dates
info = get(hObject, 'UserData');
fprintf('Lunar Illumination Percent: %f\n', info.illu);


