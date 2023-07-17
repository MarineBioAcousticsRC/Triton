% Master function to run dtRootFit then prepHTKfiles in order to take
% detected whistles, cut them into segments and write the HTK code for HMM
% models

% Note: may eventually want to include dtTonalsTracking as another
% subroutine so raw .wav files are detected as part of this function

% function = batch_whistle_to_HTK(filename);
global PARAMS masterVector

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the directory of bin or det files
% %
indir = 'F:\';  %default indir

str1 = 'Select Directory with bin or det files';
ipnamesave = indir;
indir = uigetdir(indir,str1);
if indir == 0	% if cancel button pushed
    gen = 0;
    indir = ipnamesave;
    return
else
    gen = 1;
    indir = [indir,'\'];
end

PARAMS.indir = indir;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get user input of file type, species, and detection method
type = '*.bin'; % initial values
species = 'Dd';
method = 'grd';
% user input dialog box
prompt={'Enter file type  : ','Enter species : ','Enter detection method : '};
def={char(type), char(species), char(method)};

dlgTitle=['Choose type of file (bin or det)'];
lineNo=1;
AddOpts.Resize='on';
AddOpts.WindowStyle='normal';
AddOpts.Interpreter='tex';
in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
if length(in) == 0	% if cancel button pushed
    return
end


% type of file
type = char(deal(in{1}));

% Species
species = char(deal(in{2}));

%Method of detection
method = char(deal(in{3}));

PARAMS.type = type;
PARAMS.species = species;
PARAMS.method = method;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the output directory
% %
outdir = 'F:\';  %default indir

str2 = 'Select output directory for HTK';
ipnamesave = outdir;
outdir = uigetdir(outdir,str2);
if outdir == 0	% if cancel button pushed
    gen = 0;
    outdir = ipnamesave;
    return
else
    gen = 1;
    outdir = [outdir,'\'];
end

PARAMS.outdir = outdir;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[pathlist files paths] = utFindFiles(type,PARAMS.indir,1);

advance_ms = 2; %NOTE: This is a hardwired value of 2 ms to match the
%whistle dector and dtRootFit

import java.util.LinkedList;
import tonals.*;
% Initialize
newInflectionFinder = InflectionFinder();
% Set path
newInflectionFinder.setFilePath(PARAMS.indir);
HTKTonalList = LinkedList;

%loop through each detection file and run through dtRootFit, then
%concatenate the resulting smoothed_tonal files into one large java file;
%this loop also skips empty detection files
for i = 1:length(files)
    fid = fopen(char(pathlist(i)));
    output = fread(fid,[1,1]);
    if isempty(output) == 0;
        clear output
        fclose(fid);
        smoothed_tonals = dtRootFit(char(pathlist(i)));
        HTKTonalList.add(smoothed_tonals);
        smoothed_tonals = [];
    elseif isempty(output) == 1;
        clear output
        fclose(fid);
        continue
    end
end

% run the new java file into prepHTKFiles
PARAMS.HTKFileName = fullfile(PARAMS.outdir,[PARAMS.species,'_',PARAMS.method]);
% get size of number of files in HTKTonalList
% get size of number of whistles in given file of HTKTonalList
masterVector = java.util.Vector();

[segList,allfreq] = kmeans_batch(HTKTonalList);

batchTestPrepHTKFiles_kmeans(segList,allfreq,PARAMS.HTKFileName,PARAMS.species);
%     plotSegments(HTKTonalList.get(i));
%     hold on



% HTKMV = zeros(lengthMV,1);
% make the master vector of all freqencies into a matlab array, and output
% mfc file.
% for i = 0:lengthMV-1; HTKMV (i+1,1) = masterVector.get(i); end
% spWriteFeatureDataHTK(PARAMS.fileNames.mfcFileName, HTKMV, advance_ms, 'USER');
    
    
    
    
    
    
    