function Files = dtHTKScript(Filename, Filter)
% Files = dtHTKScript(Filename, Filter)
% Read in a set of filenames in HTK format.
% Filter is an optional string, if present only files
% which match Filter will be returned.

Files = textread(Filename, '%s');
if nargin > 1
  Retain = strfind(Files, Filter);
  RetainIdx = [];
  for k=1:length(Files)
    if ~ isempty(Retain{k})
      RetainIdx = [RetainIdx; k];
    end
  end
  Files = Files(RetainIdx);
end
