function    [ch_names,descr,ch_nums,cal] = d3channames(ch)
%
%    [ch_names,descr,ch_nums,cal] = d3channames(ch)
%     Extract sensor channel names and descriptions from
%     the sensor definitions file in the D3 distribution.
%     ch is a list of sensor numbers or names for which
%     numbers, names and/or descriptions are required. 
%
%     Returns:
%     uchans is a vector of sensor channel numbers following the D3 
%        sensordefs codes.
%     channames is a cell array of sensor channel names.
%     descr is a cell array of sensor channel descriptions.
%     cal is a cell array of calibration structure field names.
%
%     Example:
%     Convert sensor channel numbers to names
%     [names,descr] = d3channames([37121 37123])
%     Convert sensor channel names to numbers
%     [names,descr,nums] = d3channames({'D2_MX','D2_MZ'})
%     Get a list of all sensor channels
%     [names,descr,nums] = d3channames
%
%     mark johnson
%     May 2012

ch_names = {} ;
ch_nums = [] ;
descr = {} ;
cal = {} ;

% read the sensor definitions file
S = readcsv('d3sensordefs.csv') ;
ch_names = stripquotes({S(:).name}) ;
descr = stripquotes({S(:).description}) ;
ch_nums = str2num(strvcat(S(:).number)) ;
cal = stripquotes({S(:).cal}) ;

if nargin<1 | isempty(ch),
   return
end

if iscell(ch) | isstr(ch),
   [kk,k] = ismember(ch,ch_names) ;

else
   [kk,k] = ismember(ch,ch_nums) ;
end
   
if any(k==0),
   fprintf('Warning: unknown sensor types in ch - skipping\n') ;
   k = k(k~=0) ;
end
ch_nums = ch_nums(k) ;
ch_names = {ch_names{k}} ;
descr = {descr{k}} ;
cal = {cal{k}} ;
ch_nums = ch_nums(:) ;
if length(ch_nums)==1,
   ch_names = ch_names{1} ;
   descr = descr{1} ;
end
