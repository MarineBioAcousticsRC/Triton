function mk_headSummary(k)

global PARAMS

%Sector 0:
PARAMS.headall.disktype(:,k) = PARAMS.head.disktype;
PARAMS.headall.disknumberSector0(k) = PARAMS.head.disknumberSector0;

%Sector 2:
% dir sector
PARAMS.headall.firstDirSector(k) = PARAMS.head.firstDirSector;
PARAMS.headall.currDirSector(k) = PARAMS.head.currDirSector;

% file sector
PARAMS.headall.firstFileSector(k) = PARAMS.head.firstFileSector;
PARAMS.headall.nextFileSector(k) = PARAMS.head.nextFileSector;

% file number
PARAMS.headall.maxFile(k) = PARAMS.head.maxFile;
PARAMS.headall.nextFile(k) = PARAMS.head.nextFile;

% misc
PARAMS.headall.samplerate(k) = PARAMS.head.samplerate;
PARAMS.headall.disknumberSector2(k) = PARAMS.head.disknumberSector2;
PARAMS.headall.firmwareVersion(:,k) = PARAMS.head.firmwareVersion;
PARAMS.headall.description(:,k) = PARAMS.head.description;
PARAMS.headall.disksizeSector(k) = PARAMS.head.disksizeSector;
PARAMS.headall.unusedSector(k) = PARAMS.head.unusedSector;

% timing error eval
% sz = size(PARAMS.head.dirlist);
% PARAMS.headall.numFilesTested(k) = sz(1);
% PARAMS.headall.numFilesTested(k) = PARAMS.head.nextFile;
PARAMS.headall.numTimingErrors(k) = PARAMS.head.numTimingError;
