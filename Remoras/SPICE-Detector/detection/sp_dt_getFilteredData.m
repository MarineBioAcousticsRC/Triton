function [filteredData] = sp_dt_getFilteredData(fid,start,stop,hdr,...
    p,fullFiles)

if p.filterSignal
    wideBandTaps = length(p.fB);
    duration = stop - start;
    duration_samples = duration * hdr.fs;
    if duration_samples <= 3*wideBandTaps
        % if data is too short for our filter, read a little more
        % on either side making sure not to go past the beginning/
        % end of file.
        pad_s = (wideBandTaps*3) / hdr.fs;
        start = max(0, start - pad_s);
        stop = stop + pad_s;
        if hdr.start.dnum + datenum([0 0 0 0 0 stop]) > hdr.end.dnum
            stop = (hdr.end.dnum - hdr.start.dnum) * 24*3600;
        end
    end
end
% read in the data
data = sp_io_readXWAV(fid, hdr, start, stop, p.channel, fullFiles);

if p.filterSignal
    % filter the data
    filteredData = filtfilt(p.fB,p.fA,data);%[],2);
    filteredData = filteredData(:,wideBandTaps+1:end);
else
    filteredData = data;
end