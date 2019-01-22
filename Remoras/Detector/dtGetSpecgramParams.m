function params = dtGetSpecgramParams(Filename)
% params = dtGetSpecgramParams(Filename)
% Retrieve short-time spectral detection parameters.  
% Retrieves parameters from the specified file.  
% When Filename is empty, retrieves from global PARAMS
% structure.

if ~ isempty(Filename)
  io = ioLoadHandlePropList(Filename);
  fromHandles = false;
else
  fromHandles = true;
end


