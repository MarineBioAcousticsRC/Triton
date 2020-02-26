function savexwavs(time, dvec, d)

% time is the detection time (abstime variable)
% calls corresponds to the TotalCalls variable
% write an xwav of each B call detection

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this next bit is from filepd.m 'saveasxwav' by SMW
% cd2current;

global HANDLES PARAMS DATA

    DATA = d;
    outfiletype = '.x.wav';
    PARAMS.outpath = PARAMS.inpath;
    PARAMS.outfile = ([PARAMS.xhd.ExperimentName,'_Bcalls_',datestr(time, 'yymmdd_HHMMSS'),outfiletype]);
    
        % in case there are multiple calls in the same window?
%     if calls > 1
% 
%         for m = 1
%             PARAMS.outfile = ([PARAMS.xhd.ExperimentName,'_Bcalls_',datestr(time, 'yymmdd_HHMMSS'),outfiletype]);
%         end
% %         for m = 2:calls
% %             PARAMS.outfile = ([PARAMS.xhd.ExperimentName,'_Bcalls_',datestr(time, 'yymmdd_HHMMSS'),'_',num2str(m),outfiletype]);
% %         end
% 
%     end
    
    len = length(PARAMS.outfile);
    if len > 4 & ~strcmp(PARAMS.outfile(len-5:len),outfiletype)
        PARAMS.outfile = [PARAMS.outfile];
    end
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(PARAMS.outfile),'0')
        return
%     else % give user some feedback
%         disp_msg('Write File: ')
%         disp_msg([PARAMS.outpath,PARAMS.outfile])
    end
    % write xwav header into output file
    writexwavhd(dvec)
    % dump data to output file
    % open output file
    fod = fopen([PARAMS.outpath,PARAMS.outfile],'a');
%       fod = fopen(
    %fseek(fod,PARAMS.xhd.byte_loc,'bof');
    if PARAMS.nBits == 16
        dtype = 'int16';
    elseif PARAMS.nBits == 32
        dtype = 'int32';
    else
        disp_msg('PARAMS.nBits = ')
        disp_msg(PARAMS.nBits)
        disp_msg('not supported')
        return
    end
    fwrite(fod,DATA,dtype);
    fclose(fod);
    disp(['B call - ',PARAMS.outpath,PARAMS.outfile])