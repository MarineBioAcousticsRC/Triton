function name = mk_xwav_name(prefix, df, rfNum)
% create XWAV file name

    global PARAMS
    
    date = num2str(PARAMS.head.dirlist(rfNum,2:4),'%02d');
    time = num2str(PARAMS.head.dirlist(rfNum,5:7),'%02d');
    % add df to filename if df not 1
    if df ~= 1
        name = sprintf('%s%s_%s_df%d.x.wav', prefix,date,time,df);
    else
        name = sprintf('%s%s_%s.x.wav', prefix,date,time);
    end
end