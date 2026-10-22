function    d3 = readd3xml(xmlfile)
%    d3 = readd3xml(xmlfile)
%     Read a D3 format xml file. This is a front-end
%     for the xml2mat function in the XML4MATv2 toolbox
%     available on the Mathworks user contributed website.
%     Make sure that toolbox is on your matlab path before
%     using this function.
%
%     mark johnson
%     25 march 2012

warning off MATLAB:REGEXP:deprecated
y=strrep(file2str(xmlfile),'''','''''') ;
if isempty(y),
   d3 = [] ;
   return
end

% replace any '-' with '_' in tags because matlab doesn't handle them
kk = find(y=='-') ;
for k=1:length(kk),
   if(rem(sum(y(1:k(1)-1)=='"'),2)==0)
      y(kk(k)) = '_' ;
   end
end

% convert first to MbML compliant string and then onto an m-variable
y=xml2mat(mbmling(y,0));
y=consolidateall(y);
warning on MATLAB:REGEXP:deprecated

% loop through the structure looking for unneeded arrays
fn = fieldnames(y) ;
d3 = struct ;
n = length(y) ;
if n==1, d3=y; return, end

for k=1:length(fn),
   for kk=1:n,
      v{kk} = getfield(y,{kk},fn{k}) ;
      if ~isempty(v{kk}),
         kg = kk ;
      end
   end

   if kg==1,
      d3 = setfield(d3,fn{k},v{1}) ;
   else
      d3 = setfield(d3,fn{k},{v{1:kg}}) ;
   end
end
