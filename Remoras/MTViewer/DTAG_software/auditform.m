function    frame = auditform
%
%

frame = [] ;
% globals
frame.name = 'audit' ;
frame.prefix = 'aud' ;
frame.shortcut = 'a' ;  % letter to press in the logtool screen for this form to appear
frame.summary = {'cue','stype'} ;

% fields

field = struct ;
   field.tag='cue' ;
   field.name='cue' ;
   field.type='number' ;
   field.min=0 ;
   field.max=1e6 ;
   field.format = '%5.1f' ;
   field.help='time of event in seconds since tagon' ;
   frame.field{1} = field ;

field = struct ;
   field.tag='duration' ;
   field.name='duration' ;
   field.type='number' ;
   field.min=0 ;
   field.max=1000 ;
   field.format = '%3.1f' ;
   field.help='duration of the event in seconds' ;
   frame.field{end+1} = field ;

field = struct ;
   field.tag='type' ;
   field.name='type' ;
   field.type='string' ;
   field.help='sound type' ;
   field.case='upper';
   frame.field{end+1} = field ;
   
field = struct ;
   field.tag='comment' ;
   field.name='comment' ;
   field.type='string' ;
   field.help='enter any comments' ;
   frame.field{end+1} = field ;
