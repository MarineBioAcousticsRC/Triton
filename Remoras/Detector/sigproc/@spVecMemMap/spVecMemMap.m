function v = spVecMemMap(Filename, N, precision, writable)
% w = spVecMemMap(File, N, precision, writable)
% Memory mapped vector support
%
% The contents of filename will be mapped to memory, resulting in an
% object that can be very large without overcommitting memory.  If the
% file does not exist, it will be created.  The special filename []
% will result in a temporary file being created.  As Matlab does not
% support destructor methods, the file will not be deleted, but  
% operating systems typically clean up older files in the designated 
% tempoary file directory.  Note that there is no attempt to provide
% security and additional development would be required to use this
% object in security sensitive situations.
%
% The precision argument indicates the type of object, use 'double' for
% Matlab's standard double precision arguments, see the documentation
% for memmapfile for a valid list of precision types.
%
% The writable argument (true/false) indicates whether or no the vector is mutable.
% If the object is writable, any changes will be written to disk and will
% thus be persistent across invocations of Matlab.
%
% In general, the vector object can be treated like any other Matlab vector,
% with the restriction that it cannot be resized.
%
% CAVEAT:  Matlab does not support a destructor method.  Consequently, 
% Matlab cannot remove a temporary file when it goes out of scope.
% The method rm_from_disk will remove the temporary file used to store
% the vector.  When the filename is specified, rm_from_disk produces
% a warning but does not remove the file.
%
% This code is copyrighted 2006 Marie Roch.
% e-mail:  marie.roch@sdsu.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

if ~ isempty(Filename)
  v.filename = Filename;
  v.file_tmp = true;
else
  v.filename = tempname;
  v.file_tmp = false;
end

v.precision = precision;
v.writable = writable;
v.memmap = [];  % reserve field for memory map
v.file_new = ~ exist(Filename, 'file');
v.valid = true;

% Create class
v = class(v, 'spVecMemMap');

% prepare file 
if v.file_new
  CreateFile(v, N)
else
  fprintf('To add:  Checks for appropriate size/write permission\n');
end

v.memmap = memmapfile(v.filename, 'format', v.precision, 'writable', v.writable);

