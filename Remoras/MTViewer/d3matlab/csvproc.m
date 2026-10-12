function       S = csvproc(fname,cols,mincols,skip,maxlines)
%
%     S = csvproc(fname,cols,mincols,skip,maxlines)
%     Read data from a CSV file into a cell array of strings
%     fname is the full file name of the file to open
%     cols is a vector of field numbers to extract. To extract all the
%        fields, use cols=[]
%     mincols is the minimum number of fields that a line must have in
%        order to be processed (this is useful for bypassing incorrect
%        short lines). If no minimum is required, use mincols=[]
%     skip is the optional number of lines to skip at the beginning of
%        the file before extracting fields. Default is 0.
%     maxlines is an optional maximum number of lines to extract. Default
%        is to extract all lines.
%
%     To convert a cell array containing only numbers to a matrix of numbers,
%     use: str2double(S)).
%
%     mark johnson, WHOI
%     29 October 2009

if nargin<1,
   help csvproc
   return
end

S = {} ;
nl = 1 ;
f = fopen(fname,'rt') ;
if f<0,
   fprintf('Cannot open file %s\n',fname) ;
   return
end

% skip the requested number of lines at the start of the file
if nargin>=4 & ~isempty(skip),
   for k=1:skip,
       ss = fgetl(f) ;
   end
end
  
if nargin<2
   mincols = 0 ;
   cols = [] ;
end

if nargin<3 | isempty(mincols),
   mincols = max([length(cols),max(cols)]) ;
end

if nargin<5 | isempty(maxlines),
   maxlines = Inf ;
end

if isempty(cols),
   while nl<maxlines,
      ss = fgetl(f) ;
      if isempty(ss) | ss<0, break, end
      c = find(ss==',') ;
      kk = [1 c+1;c-1 length(ss)]' ;
      if size(kk,1)<mincols, continue, end
      for k=1:size(kk,1),
         S{nl,k} = ss(kk(k,1):kk(k,2)) ;
      end
      nl = nl+1 ;
   end

else
   n = length(cols) ;
   while nl<maxlines,
      ss = fgetl(f) ;
      if isempty(ss) | ss<0, break, end
      c = find(ss==',') ;
      kk = [1 c+1;c-1 length(ss)]' ;
      if size(kk,1)<mincols, continue, end
      for k=1:n,
         S{nl,k} = ss(kk(cols(k),1):kk(cols(k),2)) ;
      end
      nl = nl+1 ;
   end
end

fclose(f) ;
return
