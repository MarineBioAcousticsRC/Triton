function dnum = timenum( sinput, stype )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% timenum.m
%
% this function timenum.m can be used instead of datenum.m to
% convert string time in format made from timestr.m (which is used to solve the
% rounding problems created by datestr.m and outputs msecs and usecs)
%
% Parameters:
%       sinput - the string to be converted
%       stype - the type of sting you passed in.
%           1 : mm/dd/yyyy HH:MM:SS.mmm.uuu
%           2 : HH:MM:SS.mmm.uuu
%           3 : mm/dd/yyyy
%           4 : HH:MM:SS
%           5 : mmm.uuu
%           6 : mm/dd/yyyy HH:MM:SS
%           7 : yy/mm/dd HH:MM:SS
%
% Return:
%       dnum - the datenum of the string passed in.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

yoffset = 2000; % year offset

if ~isstr( sinput )
    disp_msg( 'Error: input is not string' )
    dnum = 0;
    return
end

if stype == 1
  % split date string
  split_string = regexp(sinput, '\s', 'split');
  date = regexp(split_string{1}, '/', 'split');
  time = regexp(split_string{2}, '(:|\.)', 'split');
  if length(date) ~= 3 || length(time) ~= 5
    disp_msg( 'Error: wrong format for type == 1' )
    dnum = 0;
    return
  end
  
  sec1 = str2num( time{4} ) / 1e3 + str2num( time{5} ) / 1e6;
  date = [date{1} '/' date{2} '/' date{3} ' ' time{1} ':' time{2} ':' time{3}];
  dnum = datenum( round( datevec( date ) ) + [-yoffset 0 0 0 0 sec1]);
  
elseif stype == 6
  if length(sinput) ~= 19
    %       if approx
    %         disp_msg('Error: wrong format for type == 6, trying best match')
    %         dnum = approximate_date( string, '/|:|\s' );
    %       else
    disp_msg('Error: wrong format for type == 6')
    return
  end
  dnum = datenum( round(datevec(sinput(1:19))) - [yoffset 0 0 0 0 0] );
end

% no calls to this function, so comment out?  smw 140626
%   function dnum = no_lead_zeros(string)
%     if length( string ) == 27
%       sec1 = str2num( string( 21:23 ) ) / 1e3 + str2num( string( 25:27 ) ) / 1e6;
%       dnum = datenum( round( datevec( string( 1:19 ) ) ) + [-yoffset 0 0 0 0 sec1]);
%       return
%     end
%     split_string = regexp(string, '\s', 'split');
%     date = regexp(split_string{1}, '/', 'split');
%     time = regexp(split_string{2}, ':', 'split');
%     
%   end
end

% function dnum = approximate_date( string, expr )
%   %This algorithm will approximate the string when it's in the wrong format
%   %it first checks for syntatic errors, no semi colons or slashes, then
%   month = 0;
%   day = 0;
%   year = 0;
%   hour = 0;
%   minute = 0;
%   second = 0;
%
%   %Split the strings at with the expressions
%   [date,time] = regexp(string, '\s', 'split');
%   date = regexp(date, '/', 'split');
%   time = regexp(string, ':', 'split');
%   if stype == 6
%     diff = 6 - length(token);
%
%     if length(token{1}) ~= 2
%       month = 1;
%     end
%     if length(token{2}) ~= 2
%       day = 1;
%     end
%     if length(token{3}) ~= 4
%       year = 1;
%     end
%     if length(token{4}) ~= 2
%       hour = 1;
%     end
%     if length(token{5}) ~= 2
%       minute = 1;
%     end
%     if length(token{6}) ~= 2
%       seconds = 1;
%     end
%   end
% end