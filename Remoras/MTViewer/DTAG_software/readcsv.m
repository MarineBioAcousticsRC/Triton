function       [X,headers] = readcsv(fname,comment,hdr)
%
%     [X,fields] = readcsv(fname,comment,hdronly)
%     Read data from a CSV file. The file is assumed to have a list of column
%     names in the first line followed by lines of data. Each line must have the
%     same number of elements as the first line. Empty cells are allowed.
%     Full line comments are allowed at any line and must be preceded by the 
%     comment character (e.g., '%').
%     readcsv returns a structure array of strings with the field names taken
%     from the headers. For a rectangular cell array of strings (nentries x nfields)
%     use struct2cell(X)
%     To convert a column containing only numbers to a vector of numbers,
%     use: str2num(strvcat(X(:).field))  where field is the name of a field
%     in structure X.
%     To read only the header of the file, put hdr=1.
%     If the CSV file does not have a header, put hdr=-1. In this case,
%     the function will return a cell array with the contents of the file.

if nargin<2 | isempty(comment),
   comment = '' ;
end

X = {} ;
headers = {} ;

f = fopen(fname,'rt') ;
if f<0,
   fprintf('Cannot open file %s\n',fname) ;
   return
end

if nargin<3 | isempty(hdr),
   hdr = 0 ;
end

lk = 0 ;                                  % line count
if hdr>=0,
   while 1,
      hh = fgetl(f) ;
      lk = lk+1 ;
      if hh<0, break, end
      headers = parseline(hh,comment) ;     % break header into field names
      if ~isempty(headers), break, end
   end
end

if ~isempty(headers) & headers{1}(1)~='"',
   headers = {} ;
   frewind(f) ;
end

nfields = length(headers) ;
if hdr>0, return, end

% read remainder of the file into a cell of strings
S = {} ;
while 1,
   ss = fgetl(f) ;
   lk = lk+1 ;
   if isempty(ss) | ss<0, break, end
   x = parseline(ss,comment) ;
   if isempty(S) & nfields==0,
      nfields = length(x) ;
   end
   if length(x)==nfields,
      [S{1:nfields,end+1}] = deal(x{:}) ;
      continue
   end

   if length(x)>nfields,
      fprintf('Too many columns on line %d of file %s\n',lk,fname) ;
      fclose(f) ;
      return
   elseif ~isempty(x) & length(x)<nfields,
      fprintf('Too few columns on line %d of file %s\n',lk,fname) ;
      fclose(f) ;
      return
   end
end

fclose(f) ;
if isempty(headers), X = S' ; return, end

% make structure with field names taken from the header
headers = stripquotes(headers,1) ;
% check field names to make sure they have no illegal characters
for k=1:length(headers),
   h = headers{k} ;
   h(ismember(h,'-/\ ')) = '_' ;
   headers{k} = h ;
end
if ~isempty(S),
   X = cell2struct(S,headers,1) ;
end
return


function    x = parseline(s,comment)
%
%
%

x = {} ;
if isequal(s(1),comment),
   return
end

s = deblank(s) ;
if s(end)==',',
   endfield = 1 ;
else
   endfield = 0 ;
end

while ~isempty(s),
   if s(1)=='"',
      k = strfind(s,'",') ;
      if isempty(k),
         if s(end)=='"',
 %           x{end+1} = s(2:end-1) ;
            x{end+1} = s ;
         end
         break ;
      else
 %        x{end+1} = s(2:k(1)-1) ;
         x{end+1} = s(1:k(1)) ;
         s = s(k(1)+2:end) ;
      end
   else
      k = find(s==',') ;
      if isempty(k),
         x{end+1} = s(1:end) ;
         break ;
      else
         x{end+1} = s(1:k(1)-1) ;
         s = s(k(1)+1:end) ;
      end
   end
end

if endfield==1,
   x{end+1} = '' ;
end
return
