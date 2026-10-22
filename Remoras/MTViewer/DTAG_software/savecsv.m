function    savecsv(fname,hdr,s)
%
%    savecsv(fname,hdr,s)
%     Create a CSV file with header hdr and content
%     equal to a cell array of strings s, one cell for each field. 
%     hdr can be a FORM structure or a cell array of strings. 
%

[f,msg] = fopen(fname,'wt') ;
if f<0,
   logtoolerror(msg) ;
   return
end

if isstruct(hdr) & isfield(hdr,'field'),     % if hdr is a form
   hdr = getsubfields(hdr.field,'tag') ;     % get the field tags
end

if ~iscell(hdr),
   logtoolerror('Error in savecsv: header must be a form or a cell array of strings') ;
   return
end

ss = strcat('"',hdr,'",') ;             % add quotes to each field name
ss = horzcat(ss{:}) ;                   % and concatenate to make a string
ss(end) = char(10) ;                    % replace trailing comma with an end-of-line char

if nargin<=2,
   fwrite(f,ss,'char') ;
   fclose(f) ;
   return
end

nrows = length(hdr) ;
[m n] = size(s) ;
if n~=nrows,
   if rem(m*n/nrows,1)~=0,
      logtoolerror('Error in savecsv: data must have an integer number of rows') ;
      return
   end
   s = reshape(s,[],nrows) ;
end

s = strcat(s,',') ;                     % add comma separators

for k=1:m,
   sk = horzcat(s{k,:}) ;               % concatenate each row to make a string
   sk(end) = char(10) ;                 % replace trailing comma with an end-of-line char
   ss(end+(1:length(sk))) = sk ;        % append to output string
end
fwrite(f,ss,'char') ;
fclose(f) ;
