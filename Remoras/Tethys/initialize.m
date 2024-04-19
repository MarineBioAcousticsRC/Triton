function initialize
global REMORA

REMORA.tethys.version = 3.0;

if ~ isdeployed % Execute in an interpreted Matlab environment
  [tethroot, ~] = fileparts(mfilename);

  for dir = ["MatlabClient/db", "MatlabClient/db/c", "MatlabClient/vis"]
      addpath(tethroot, dir);
  end
end
