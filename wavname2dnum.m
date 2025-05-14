function [dnums] = wavname2dnum(filenames, dispOn)
% Parses .wav file names and converts them to matlab datenums
% Works on single or multiple file names
% Supports 7 filename formats:
%   1.  yymmdd-HHMMSS
%   2.  yymmdd_HHMMSS
%   3.  yymmddTHHMMSSZ
%   4.  yymmddHHMMSS
%   5.  yyyymmdd_HHMMSS 
%   6.  yyyymmddTHHMMSSZ
%   7.  yyyymmddHHMMSS_FFF

% This matches both underscores and hyphens, but don't know how to handle
% the datenum formatting...maybe useful later?
% regexp(fname,'\d{4}[-_]\d{4}','match','split')

if nargin <2
    dispOn = true; % added to limit printing of dnum format during LTSA creation
end

% start with the default date format
filenamesc = cellstr(filenames);
date_strs = regexp(filenamesc,'\d{6}[-]\d{6}','match'); 
date_fmt = 'yymmdd-HHMMSS';

if isempty(date_strs{1}) % have to try this one before 12 or 6_6
    date_fmt = 'yyyymmddHHMMSS_FFF';
    date_strs = regexp(filenamesc,'\d{14}[_]\d{3}','match' );
    if ~isempty(date_strs{1}) && dispOn
        disp('Using DMON filename format yyyymmddHHMMSS_FFF');
    end
end

if isempty(date_strs{1}) % try avisoft or Soundtrap filename
    date_fmt = 'yymmddHHMMSS';
    date_strs = regexp(filenamesc,'\d{12}','match' );
    if ~isempty(date_strs{1}) && dispOn
        disp('Using avisoft and SoundTrap filename format yymmddHHMMSS');
    end
end

if isempty(date_strs{1}) % using underscores presumably
    date_fmt = 'yymmdd_HHMMSS';
    date_strs = regexp(filenamesc,'\d{6}[_]\d{6}','match');
end

if isempty(date_strs{1}) % not just an underscore problem, try PAMGuard filename
    date_fmt = 'yyyymmdd_HHMMSS'; % PAMGuard default file format 
    date_strs = regexp(filenamesc,'\d{8}[_]\d{6}','match');
    if ~isempty(date_strs{1}) && dispOn
        disp('Using PAMGuard filename format yyyymmdd_HHMMSS');
    end
end

if isempty(date_strs{1})
    date_fmt = 'yymmddTHHMMSSZ';
    date_strs = regexp(filenamesc,'\d{6}[T]\d{6}[Z]','match' );
    if ~isempty(date_strs{1}) && dispOn
        disp('Using ISO8601 date format yymmddTHHMMSSZ in filename');
    end
end

% this should get parsed properly by ISO8601 date format
% if isempty(date_strs{1}) % try AMAR filename - e.g., AMAR613.20190604T182000Z.wav
%     date_fmt = 'yyyymmddTHHMMSS';
%     date_strs = regexp(filenamesc,'\d{8}[T]\d{6}[Z]','match');
%     if ~isempty(date_strs{1})
%         disp('Using AMAR filename format yyyymmddTHHMMSSZ');
%     end
% end

if isempty(date_strs{1})
    disp('Unknown filename date format.  Please use one of the following:');
    disp('*yymmdd-HHMMSS*.wav');
    disp('*yymmdd_HHMMSS*.wav');
    disp('*yymmddTHHMMSSZ*.wav');
    disp('*yymmddHHMMSS*.wav'); 
    disp('*yyyymmdd_HHMMSS*.wav');
    disp('*yyyymmddTHHMMSSZ*.wav');
    disp('*yyyymmddHHMMSS*.wav'); 
    % date_fmt = 'yymmdd-HHMMSS';
    dnums = [];
	return
end 

dnums = cellfun(@(x)datenum(x,date_fmt),date_strs,'UniformOutput',false);
dnums = cell2mat(dnums)'; % output of cellfun is a cell