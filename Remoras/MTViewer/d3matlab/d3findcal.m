function    [CAL,id,cname] = d3findcal(cname)
%
%    [CAL,id,cname] = d3findcal(cname,id)
%     Retrieve calibration information for a tag
%     Examples:
%     [CAL,id] = d3findcal('d401') ;  % gets cal info for a tag by convenience name
%     [CAL,id,cname] = d3findcal('1D032215') ; % gets cal info for a tag by ID code
%     [CAL,id,cname] = d3findcal(3842187796) ; % gets cal info for a tag by ID number
%
%     markjohnson@st-andrews.ac.uk
%     26 jan 2013
%     bug fixes: FHJ, 8 april 2014

CAL = [] ; id = [] ;
if nargin == 0,
   help d3findcal
   cname = [] ; id = [] ;
   return
end

if ~isstr(cname),
   cname = dec2hex(cname) ;
end

% see if there is an xml file on the path called cname
if exist([cname '.xml'],'file'),
   readmatxml([lower(cname) '.xml']) ;
   CAL = DEV.CAL ;
   if ~isfield(CAL,'SRC'),
      CAL.SRC.ID = DEV.ID ;
      CAL.SRC.NAME = DEV.NAME ;
   end
   id = DEV.ID ;
   cname = DEV.NAME ;
   return ;
end

if length(cname)~=8,
   cname = [] ;
   return
end

% otherwise, look for a cal file for the device in the caldir
% look on the matlab path for a path name containing 'd3' and 'cal'
pp = path ;
DEV = [] ;
cname = upper(cname) ;
foundcaldir = 0 ;
while ~isempty(pp),
   [dirn,pp] = strtok(pp,';') ;
   if ~isempty(strfind(dirn,'d3')) && ~isempty(strfind(dirn,'cal')),
      foundcaldir = 1; % Quick check to see if d3cal directory has been found       
      dd = dir([dirn '\*.xml']) ;
      for k=1:length(dd),
         try,
            [rx,vname]=xml2mat([dirn '\' dd(k).name]) ;
            if strcmp(vname,'DEV') && strcmp(upper(rx.ID),cname), % cname already upper case (l. 46)
               DEV = rx ;
               break ;
            end   
         catch,
         end
      end
   end
end

if ~foundcaldir, % Give error message if the d3cal directory was not found
    disp('Did not find d3cal directory in matlab paths. Check name of directory and add to path')
end

if isempty(DEV),
   cname = [] ;
   return
end

cname = DEV.NAME ;
id = DEV.ID ;
CAL = DEV.CAL ;
CAL.SRC.ID = DEV.ID ;
CAL.SRC.NAME = DEV.NAME ;
