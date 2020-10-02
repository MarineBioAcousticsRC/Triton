function [ dnums ] = wavname2dnum( filenames )
% Parses .wav file names and converts them to matlab datenums
% Works on single or multiple file names
% Supports 5 filename formats:
%   1.  yymmdd-HHMMSS
%   2.  yymmdd_HHMMSS
%   3.  yyyymmdd_HHMMSS 
%   4.  yymmddHHMMSS
%   5.  yyyymmddTHHMMSS added for AMAR613.20190604T182000Z.wav

% This matches both underscores and hyphens, but don't know how to handle
% the datenum formatting...maybe useful later?
% regexp(fname,'\d{4}[-_]\d{4}','match','split')

% start with the default date format

filenamesc = cellstr(filenames);
date_strs = regexp(filenamesc,'\d{6}[-]\d{6}','match'); 
date_fmt = 'yymmdd-HHMMSS';


if isempty(date_strs{1})
    date_fmt = 'yymmddTHHMMSSZ';
    date_strs = regexp(filenamesc,'\d{6}[T]\d{6}[Z]','match' );
    if ~isempty(date_strs{1})
        disp('Using ISO8601 date format yymmddTHHMMSSZ in filename');
    end
end

if isempty(date_strs{1}) % not a PAMguard file, try avisoft filename
    date_fmt = 'yymmddHHMMSS';
    date_strs = regexp(filenamesc,'\d{12}','match' );
    if ~isempty(date_strs{1})
        disp('Using avisoft and SoundTrap filename format yymmddHHMMSS');
    end
end

if isempty(date_strs{1}) % not just and underscore problem, try PAMGuard filename
    date_fmt = 'yyyymmdd_HHMMSS'; % PAMGuard default file format 
    date_strs = regexp(filenamesc,'\d{8}[_]\d{6}','match');
    if ~isempty(date_strs{1})
        disp('Using PAMGuard filename format yyyymmdd_HHMMSS');
    end
end

if isempty(date_strs{1}) % using underscores presumably
    date_fmt = 'yymmdd_HHMMSS';
    date_strs = regexp(filenamesc,'\d{6}[_]\d{6}','match');
end

% added 2020 06 26 by S. Fregosi
if isempty(date_strs{1}) % try AMAR filename - e.g., AMAR613.20190604T182000Z.wav
    date_fmt = 'yyyymmddTHHMMSS';
    date_strs = regexp(filenamesc,'\d{8}[T]\d{6}','match');
    if ~isempty(date_strs{1})
        disp('Using AMAR filename format yyyymmddTHHMMSS');
    end
end

if isempty(date_strs{1})
    disp('Unknown filename date format.  Please use one of the following:');
    disp('*yymmdd-HHMMSS*.wav');
    disp('*yymmdd_HHMMSS*.wav');
    disp('*yyyymmdd_HHMMSS*.wav');
    disp('*yymmddHHMMSS*.wav'); 
    date_fmt = 'yymmdd-HHMMSS';
    dnums = [];
	return
end 

dnums = cellfun(@(x)datenum(x,date_fmt),date_strs,'UniformOutput',false);
dnums = cell2mat(dnums)'; % output of cellfun is a cell