function [startsSec,stopsSec] = sp_dt_chooseSegmentsRaw(hdr)

dnum2sec = 60*60*24;
starts = hdr.raw.dnumStart;
stops = hdr.raw.dnumEnd;
startsSec = (starts - starts(1)).*dnum2sec;
stopsSec = (stops - starts(1)).*dnum2sec;

