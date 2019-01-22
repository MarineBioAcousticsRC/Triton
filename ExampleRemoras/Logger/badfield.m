function badfield(hObjects, Messages, delay_s)
% badfield(hObject, Message, delay)
% Show Message(s) in String fields of specified GUI objects,
% set their background to red, and delay for the specified
% number of s.

% Save background and current values
bg = get(hObjects, 'BackgroundColor');
if ~ iscell(bg)
    bg = {bg};   % make single object look like the others
end
textstr = get(hObjects, 'String');
if ~ iscell(textstr)
    textstr = {textstr};  % similar
end

% Change background and set to new text
red = [1 0 0];  
set(hObjects, 'BackgroundColor', red);
if ~ isempty(Messages)
    if iscell(Messages)  % Mulitple messages
        for idx=1:length(hObjects)
            set(hObjects(idx), 'String', Messages{idx});
        end
    else
        set(hObjects, 'String', Messages);
    end
end
    
pause(delay_s);

% Restore to former glory...
for idx=1:length(hObjects)
    set(hObjects(idx), 'BackgroundColor', bg{idx}, ...
        'String', textstr{idx});
end