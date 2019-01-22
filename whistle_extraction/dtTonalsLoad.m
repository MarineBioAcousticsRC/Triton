function [tonalList, headerInfo, Filename] = dtTonalsLoad(Filename, gui)
% tonalList = dtTonalsLoad(Filename, gui)
% Load a set of tonals from Filename.  If Filename is [] or gui is true
% the filename is requested via dialog with Filename (if any) as the
% suggested default value.
%
% Filename - Example - 'palmyra092007FS192-071011-230000.bin' or
%                       []
%
% Omit gui or set it to false to simply load from the specified file.
import tonals.*

headerInfo = [];

error(nargchk(1,2,nargin));
if nargin < 2
    if isempty(Filename)
        gui = true;
    else
        gui = false;
    end
end

if gui
    [LoadFile, LoadDir] = uigetfile(...
        {'*.ann;*.bin', 'Annotation File'
         '*.det', 'Detections'
         '*.d-', 'False Detections'
         '*_s.gt+;*_s.gt-;*_s.d+', 'Above SNR ground truth and valid detections'
         '*_a.gt+;*_a.gt-;*_a.d+', 'All ground truth and valid detections'
         '*', 'All files',
         '*.ton', 'legacy tonal format (not recommended)'},...
        'Load Tonals', Filename);
    
    % check for cancel
    if isnumeric(LoadFile)
        Filename = [];
        tonalList = [];
        return
    else
        Filename = fullfile(LoadDir, LoadFile);
    end
end

[path name ext] = fileparts(Filename);
if ~strcmp(ext, '.ton')
    % loads binary file
    tonalBIS = TonalBinaryInputStream;
    
    tonalBIS.tonalBinaryInputStream(Filename);    % retrieve linked list
    tonalList = tonalBIS.getTonals(); 
    headerInfo = tonalBIS.getHeader();  
else if strcmp(ext, '.ton')
        % loads objects
        tonalList = tonals.tonal.tonalsLoad(Filename);
    end
end
