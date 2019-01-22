function fitFile = loadFitFile(fullFileName)
% kef 20110219

% loads saved fittedTonalList (fitoutput.txt)
% That output is created and saved by dtRootFit*.m

% fullFileName = complete file path and name of fitoutput file

% The methods for accessing content of fitFile are the same as for
% accessing the output of dtRootFit

import java.util.LinkedList;
import tonals.*;

[filePath, fileName, ext, versn] = ...
    fileparts(fullFileName);
filePath = [filePath,'/'];

% initiate method InflectionFinder and set path
newInflectionFinder = InflectionFinder();
newInflectionFinder.setFilePath(filePath);

newInflectionFinder.loadFittedTonals([fileName, ext]);
fitFile = newInflectionFinder.fittedTonalList;
