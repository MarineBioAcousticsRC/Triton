function       [id,fullid] = getxmldevid(fname)
%
%     [id,fullid = getxmldevid(fname)
%     Extract the DEVID sentence from a D3 xml file.
%     Returns the short id as an 8 digit number and the
%     full id as a string. fname should not have a suffix.
%
%     mark johnson
%     29 October 2009

id = [] ; fullid = [] ;

if nargin<1,
   help getxmldevid
   return
end

if isstr(fname),
   d3 = readd3xml([fname '.xml']) ;
else
   d3 = fname ;
end

if isfield(d3,'DEVID')
   fullid = d3.DEVID ;
else,
   fprintf(' XML file missing or incomplete: %s.xml\n',fname) ;
   return
end

% parse id string
ss = fullid ;
Z = {} ;
while ~isempty(ss),
   [Z{end+1},ss] = strtok(ss,',') ;
end
id = hex2dec(horzcat(Z{3:4})) ;
return
