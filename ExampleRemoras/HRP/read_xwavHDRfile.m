function read_xwavHDRfile(hdrfilename,d)
%
% usage: >> read_xwavHDRfile(hdrfilename,d)
%
%
% hdrfile format:
%
% smw 050920
% smw 060126
%

global PARAMS


% check to see if file exists 
if exist(hdrfilename)
    % open hdr file
    [fid,message] = fopen(hdrfilename, 'r');
    if message == -1
        disp(['Error - no file ',hdrfilename])
        return
    end
end

% display flag: display values = 1
if d
    dflag = 1;
else
    dflag = 0;
end

% read each line of the hdrfile and evaluate it
while ~feof(fid)            % not EOF
    tline=fgets(fid);
    eval(tline)
    if dflag
        disp(tline)
    end
end

% close hdr file
fclose(fid);
