% copy of startup.m (Ainsleigh Lloyd)
%  Example startup script file for Matlab tag tools
%
%  Edit this file to notify Matlab about where you are keeping the standard
%  dtag data file types 'CAL','RAW','PRH','AUDIO','AUDIT'
%  Can also add specific instructions you want to happen every time Matlab
%  starts.
%

% change each path here to the correct one for your pc
% recommendations are:
%     cal      'c:/tag/metadata/cal'
%     raw      'c:/tag/metadata/raw'
%     prh      'c:/tag/metadata/prh'
%     audit    'c:/tag/metadata/audit'
%     audio    this might be an external hard drive, in which case
%              remember to include the drive letter
% 
% settagpath('cal','c:/tag/tag2/metadata/cal');
% %settagpath('raw','c:/tag/data/raw');
% settagpath('prh','c:/tag/tag2/metadata/prh');
% settagpath('audit','c:/tag/tag2/metadata/audit') ;
% 
% % if using an external hard drive for the audio data, avoid a warning message 
% % by checking to see if the external drive is plugged in
% if exist('e:','dir')
%    settagpath('audio','e:');
% end

% change to your working directory
%cd /tag/matlab/work

% say something nice to the screen
fprintf('Tag tools installed\n\n')
