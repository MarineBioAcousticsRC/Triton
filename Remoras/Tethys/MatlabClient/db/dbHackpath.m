function dbHackpath(paths)
% dbHackpath(paths)
% Adds jar files to Matlab's static path.
% Libraries with class loaders usually fail if added dynamically.
% This is a hack.
% javaclasspath will not show the libraries, but they are there.

import dbxml.ClassPathHacker;
hacker = ClassPathHacker();
for idx = 1:length(paths)
    hacker.addFile(paths{idx});
end