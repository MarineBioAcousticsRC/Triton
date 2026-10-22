function s=file2str(x)

%FILE2STR reads textfile into a single long string
%
% Syntax: s=file2str(x)
%
% Description
%   x is a filename
%   s is the long string with all contents
%
% Jonas Almeida, almeidaj@musc.edu, 30 June 2003, MAT4NAT Tbox
% Fixed to return an empty string if the file is empty
% mj July 2012

s = '' ;
fid=fopen(x,'r');
if fid<0, return, end
i=1;
y = {} ;
while ~feof(fid)
   yy = fgetl(fid);
   if ischar(yy),
      y{i} = yy ;
      i=i+1;
   end
end
fclose(fid);
if length(y)>0,
   s=strcat(y{:});
end
