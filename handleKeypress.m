function handleKeypress( src, evnt )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% handleKeypress.m
%
% handles keyboard shortcuts
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global HANDLES handles PARAMS 

% figure out how many subplots needed
savalue = get( HANDLES.display.ltsa,'Value' );
tsvalue = get( HANDLES.display.timeseries,'Value' );
spvalue = get( HANDLES.display.spectra,'Value' );
sgvalue = get( HANDLES.display.specgram,'Value' );

%determine which modifiers have been pressed. 
if ~isempty( evnt.Modifier )
    switch( evnt.Modifier{1} )
        case 'control'
            theKey = 'CtrlKeys';
        case 'alt'
            theKey = 'AltKeys';
        case 'shift'
            theKey = 'ShiftKeys';
    end
else
    theKey = 'DefaultKeys';
end

%make keypress struct
struct = eval( [ 'PARAMS.keypress.', theKey ] );
if isfield(struct, 'Key')%make sure that a key field is there
    for x = 1:length( struct.Key )
        if strcmp( evnt.Key, struct.Key( x ).name )%find the matching key
            if eval( struct.Key( x ).param )
                eval( struct.Key( x ).fn )
                break;  
            end
            break; %no duplicate key press so end loop
        end
    end
end