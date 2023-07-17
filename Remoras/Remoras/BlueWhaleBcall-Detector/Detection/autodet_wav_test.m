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
%thresh =  REMORA.bw.settings.thresh; %detection threshold, was 30, lowered it to 10 to see how function works.
thresh = 15;
%% Get list of wav files in deployment and define output
%Get all wavs in that deployment
% WavDir = 'G:\MB01_01_df48\';
WavDir = 'F:\CI01_01_df8';
%WavDir = REMORA.bw.settings.inDir;
SearchFileMaskMat = {'*wav'};
SearchPathMaskMat = {WavDir};
SearchRecursiv = 0;

[PathFileListWav, FileListWav, PathListWav] = ...
    utFindFiles(SearchFileMaskMat, SearchPathMaskMat, SearchRecursiv);

%Define output files
OutDir = 'G:\Shared drives\Soundscape_Analysis\trial_output'; %NB: the drive letter changes quite often, so check.
%OutDir = REMORA.bw.settings.outDir;
PathListCsv = PathListWav;
FileListCsv = FileListWav;

for l = 1:length(PathListCsv)
    path = PathListCsv{l};
    path = strrep(path,path,OutDir);
    PathListCsv{l} = path;
end

for l = 1:length(FileListCsv)
    file = FileListCsv{l};
    file = strrep(file,'wav','csv'); %make sure 'x.wav' is the correct extension that is altered.
    FileListCsv{l} = file;
end

for l = 1:length(FileListCsv)
    PathFileListCsv{l} = fullfile(PathListCsv{l},FileListCsv{l});
end

%% find start times from each file for Sound Trap data
RegDate = '(?<yr>\d\d)(?<mon>\d\d)(?<day>\d\d)(?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)';
fileDates = dateregexp(FileListWav,RegDate);

%%
% 
block = 3600;   % s - hourly increments
gap = zeros([1,length(PathFileListWav)]); %duty cycle data
fileEnd = fileDates;
halfblock = block/2;
offset = zeros([1,length(PathFileListWav)]);

for fidx = 1:3   %length(PathFileListWav)
    %Write into excel sheet
    out_fid = fopen(PathFileListCsv{fidx}, 'a');   % Open xls file to write to
    %hdr = PathFileListWav{fidx};
    
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
    totalsec = I.Duration;
    fileEnd(fidx)=startTime + (I.Duration/24/3600);
    blocknum = ceil(totalsec/block); %how many times will the whole window fit
   
    %start and end times in sample points for first file
   
    if fidx == 1
        gap = 0;
        offset = 0;
    else
        gap(fidx) = floor((startTime - ...
            fileEnd(fidx-1)) * 24 * 60 * 60);

        % Calculate the cumulative offset in scheduled gaps per raw file
        offset(fidx) = offset(fidx-1) + gap(fidx); % will give cumulative gap time so far
    end
   
for blockIdx = 1:blocknum  %scroll through blocks
    if blockIdx == 1
        startS = 1;
        endS = block*I.SampleRate;
    else
        startS = (blockIdx-1)*block*I.SampleRate;
        endS = (blockIdx)*block*I.SampleRate;
    end
    if endS > I.TotalSamples
        endS = I.TotalSamples;
    end
        
        % Read in data
        y = audioread(filename, [startS endS]);
        findcalls_soundtrap(y,I,blockIdx,startTime,endTime,startF,endF,thresh,block,halfblock,offset(fidx),out_fid,1); %Waar gaat de output naartoe?
        
end

    
    fclose(out_fid);
end
end 
%end
 