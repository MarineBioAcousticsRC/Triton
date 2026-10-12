%
%  Example startup script file for Matlab tag tools
%
%  Edit this file to notify Matlab about where you are keeping the standard
%  dtag data file types 'CAL','RAW','PRH','AUDIO','AUDIT'
%  Can also add specific instructions you want to happen every time Matlab
%  starts.
%

% change each path here to the correct one for your pc
% recommendations are:
%     cal      'E:\AcousticTags\data\Zc_Tags\zc11\zc11_267a\cal'
%     raw      'E:\AcousticTags\data\Zc_Tags\zc11\zc11_267a\raw'
%     prh      'E:\AcousticTags\data\Zc_Tags\zc11\zc11_267a\prh'
%     audit    'c:/tag/metadata/audit'
%     audio    this might be an external hard drive, in which case
%              remember to include the drive letter
% 
 settagpath('cal','E:\AcousticTags\data\Zc_Tags\zc13\zc13_210a\cal');
 %settagpath('E:\AcousticTags\data\Zc_Tags\zc11\zc11_267a\raw');
 settagpath('E:\AcousticTags\data\Zc_Tags\zc13\zc13_210a\prh');
% settagpath('audit','c:/tag/tag2/metadata/audit') ;
% 
% % if using an external hard drive for the audio data, avoid a warning message 
% % by checking to see if the external drive is plugged in
% if exist('e:','dir')
%    settagpath('audio','e:');
% end

% change to your working directory
cd E:\AcousticTags\data\Zc_Tags
% say something nice to the screen
fprintf('Tag tools installed\n\n')
