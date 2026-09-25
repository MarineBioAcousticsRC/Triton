function check_dirlist_times(filenames)
%
% check_dirlist_times
%
% asks for one file or whole directory, then get recording parameters and
% run difftime_dirlist for one file or whole directory
%
% called from toolpd
%
% 061030 smw
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES

get_recordingparams;  % get recording parameters

if size(filenames, 1) == 1
        disp_msg_log('on')
        difftime_dirlist(filenames,2);
        if PARAMS.head.numTimingError > 1
            figure(HANDLES.fig.main)
            if max(PARAMS.head.baddirlist(:,2)) ~= min(PARAMS.head.baddirlist(:,2))
                dh = ceil(max(PARAMS.head.baddirlist(:,2)) - min(PARAMS.head.baddirlist(:,2)));
            else
                dh = 10;
            end
            hist(PARAMS.head.baddirlist(:,2),dh)
            title(filenames)
            xlabel('Time between successive Directory Listings [seconds]')
            ylabel('Number')
        end
        disp_msg_log('off');
        
        % save timecheck summary
        timeck = [filenames(1:end-4), '_timeck.txt'];
        disp('   ')
        disp(['Time Check Message File: ' timeck])
        
        fod = fopen(timeck, 'w+');
        for x = 1:length(PARAMS.msgs)
           fprintf(fod, '%s\r\n', PARAMS.msgs{x});
        end        
else
%    d = dir(fullfile(PARAMS.inpath,'*head.hrp'));    % hrp head files
    for k = 1:size(filenames,1)
        filename = filenames(k, :);
        
        disp_msg_log('on');
        difftime_dirlist(filename,2);
        mk_headSummary(k);
        disp_msg_log('off');
        
         % save timecheck summary
        timeck = [filename(1:end-4), '_timeck.txt'];
        disp('   ')
        disp(['Time Check Message File: ' timeck])
        
        fod = fopen(timeck, 'w+');
        for x = 1:length(PARAMS.msgs)
           fprintf(fod, '%s\r\n', PARAMS.msgs{x});
        end        
    end
    
    disp_headSummary(size(filenames, 1));
end


% write messages to timecheck file

