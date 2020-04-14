function autodet_wav(WavDir, OutDir)

% scroll through xwav file - adapted from Shyam's BatchClassifyBlueCalls
% smk 100219

% ideal for window lengths greater than 1 raw file (75s).  As is, raw file
% length in seconds must be hard-coded.  If raw files are ever NOT 75s,
% code must be adapted.

% modified by Anjali Boyd and Simone Baumann-Pickering September 9, 2019

%% Define settings to provide to findcalls.m
startF    = [45, 44.5, 44, 43.5];	% Hz - start frequency kernel
endF      = [44.5, 44, 43.5, 42.7];	% Hz - end frequency kernel
thresh = 30; %detection threshold

%% Get list of wav files in deployment and define output
%Get all wavs in that deployment
% WavDir = 'G:\MB01_01_df48\';
WavDir = '/Volumes/GoogleDrive/Shared drives/Soundscape_Analysis/code/Anjali_BCall_detector/exampleFiles/MB01_01_df48/';
SearchFileMaskMat = {'*wav'};
SearchPathMaskMat = {WavDir};
SearchRecursiv = 0;

[PathFileListWav, FileListWav, PathListWav] = ...
    utFindFiles(SearchFileMaskMat, SearchPathMaskMat, SearchRecursiv);

%Define output files
OutDir = '/Volumes/GoogleDrive/Shared drives/Soundscape_Analysis/code/Anjali_BCall_detector/exampleFiles/MB01_01_df48/out/';
PathListCsv = PathListWav;
FileListCsv = FileListWav;

for l = 1:length(PathListCsv)
    path = PathListCsv{l};
    path = strrep(path,path,OutDir);
    PathListCsv{l} = path;
end

for l = 1:length(FileListCsv)
    file = FileListCsv{l};
    file = strrep(file,'d48.wav','csv');
    FileListCsv{l} = file;
end

for l = 1:length(FileListCsv)
    PathFileListCsv{l} = fullfile(PathListCsv{l},FileListCsv{l});
end

%% find start times from each file
RegDate = '(?<yr>\d\d)(?<mon>\d\d)(?<day>\d\d)(?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)';
fileDates = dateregexp(FileListWav,RegDate);

%%
% 
block = 3600;   % s - hourly increments
gap = 0; %duty cycle data
    
for fidx = 1:length(PathFileListWav)
    %Write into excel sheet
    out_fid = fopen(PathFileListCsv{fidx}, 'a');   % Open xls file to write to
    
    
    %%%%%%%%%% 
    %1) calculate n of hours (should be just under 3) =2:59:58-59
    %2) calculate sample start and sample end for each hour;
    %shift by 30 minutes to avoid missing calls on edges
    %3) feed each hour into findcalls 
    %4) in findcalls figure out how to incrementally write to csv file,
    %e.g. dlmwrite('test.csv',N,'delimiter',',','-append');
    %5) in findcalls - detection shows as peakS, being seconds into the
    %window; export of call start - add peakS to start of window
   
    filename = PathFileListWav{fidx};
    
    %time keeping; start of file and first hourly increment
    startTime = fileDates(fidx);
    incHr = datenum([0 0 0 1 0 0]);
    endTime = startTime + incHr;
    
    I = audioinfo(filename); %info on audio file properties
   
     %start and end times in sample points for first file
    if fidx == 1
        startS = 1;
        endS = block*I.SampleRate;
    end
    
    while endS < I.TotalSamples
        % Read in data
        y = audioread(filename, [startS endS]);
        findcalls(y,I,startTime,endTime,startF,endF,thresh,block,out_fid,1);
    end

 

      
    
    findcalls(halfblock, block, gap, offset, startS, endS, ...
         PathFileListWav{fidx}, startF, endF, thresh, out_fid, 1);


    
    fclose(out_fid);
end
    
%end
 