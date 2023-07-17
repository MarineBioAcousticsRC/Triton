function dtTonalsSave(Filename, tonals, gui, savemask)
% dtTonalsSave(Filename, tonals, gui, savemask)
% Save the list of tonals to the specified file. Tonals with the extension
% .ton are saved in a legacy Java object format (implementation is a 
% memory pig).  Files not ending in .ton are saved in the Silbido 
% file format (recommended).
%
% Filename - Example - 'palmyra092007FS192-071011-230000.wav' or
%                       []
% tonals - list of tonals
%
% If Filename is [] or gui is true, a dialog is presented
% and the user is allowed to select with the default value
% being Filename.
%
% The savemask specifies what elements of the tonal will be saved
% (only applicable to the Silbido format).  The mask must be a bitwise
% or the the parameters from the Java class TonalHeader.
% Current values are TIME, FREQ, SNR, PHASE, and DEFAULT.
% The default is equivalent to:
%   import tonals.TonalHeader
%   savemask = bitor(TonalHeader.TIME, TonalHeader.FREQ);

import tonals.*;

error(nargchk(2,4,nargin));
if nargin < 4
    savemask = TonalHeader.DEFAULT;
    if nargin < 3
        gui = isempty(Filename);  % Only use the gui if filename empty
    end
end

pattern = {'*.ann', 'annotation'; '*.ton', 'legacy tonal format (not recommended)'};
if gui
    [SaveFile, SaveDir] = uiputfile(pattern, 'Save Tonals', Filename);
    if isnumeric(SaveFile)
        return  % cancel
    end
    Filename = fullfile(SaveDir, SaveFile);
end

[path name ext] = fileparts(Filename);
% open up file
if strcmp(ext, '.ton')
    % Use legacy format
    tstream = TonalOutputStream(Filename);
else
    version = 1;
    comment = 'none';
    tstream = TonalBinaryOutputStream(Filename, version, comment,...
        savemask);
end

% iterate through tonals
it = tonals.iterator();
count = 0;
while it.hasNext()
    t = it.next();
    tstream.write(t);  % write each tonal
    count = count + 1;
    if rem(count, 100) == 1 && strcmp(ext, '.ton')
        tstream.objstream.reset();
    end
end
tstream.close();
