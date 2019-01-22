function initpaths()
% initpaths()
% Set Matlab and Java search paths

% Bruce (or anyone else building a standalone package with the Matlab
% compiler):  Using mfilename will fail.  It looks like ctfroot
% will return the directory where the deployment file is stored, and 
% we can probably copy all of the java directories there.  We'll need
% to figure out how to detect if running a compiled runtime, using
% a try/catch block should work, but there may be a more elegant way.
% - Marie

% Add subdirectories to path as well as any Java resources needed
RootDir = fileparts(which(mfilename));
for d = {'db', 'vis'}
    addpath(fullfile(RootDir, d{1}));
end

dbJavaPaths();  % Add Java directories

q = dbInit();