% Generate soundscape output

%% settings

% !!!! need to make look up table for SoundTrap !!!!
%system sensity (hydrophone + recorder)
sensitivity = 176.6;

% !!!! LTSA step size in seconds
isec = 5;

% !!!! NEED TO THINK ABOUT DUTY CYCLE !!!!
dc = 1; 
outpath = 'I:\Shared drives\Soundscape_Analysis\output_calcAvg\SanctSound_CI02_01\matFiles';
pdir = 'I:\Shared drives\Soundscape_Analysis\output_calcAvg\SanctSound_CI02_01\plots';
ofroot = 'SanctSound_CI02_01'; %out file naming convention

% !!!! NEED TO THINK ABOUT FIFO !!!!
rm_fifo = 0;
% rm_fifo = 1;
% fbin = 4;  % at df100 this is 4 Hz
% sthr = 25;
block = 0; % number of seconds to block for disk write; longer for older data
keep = 12; % number of averages to keep per minute

% !!!! NEED TO THINK ABOUT STRUMMING/FLOW NOISE !!!!

%location of supporting transfer function
tf = [];
% tf = 'D:\data\documents\transfer_functions\LJ\DM01\D\818_160225\Sig1\818_161027_invSensit_Red.tf';

%List all LTSAs in that deployment
ltsaDir = 'F:\CI02_01_df48\';
% ltsaDir = 'J:\soundscape_analysis\LJ DM\LJ_DM_01_D\LJ_DM_01_D_disk01_df100\';
SearchFileMask = {'*.ltsa'};
SearchPathMask = {ltsaDir};
SearchRecursiv = 1;

[PathFileList, FileList, PathList] = ...
    utFindFiles(SearchFileMask, SearchPathMask, SearchRecursiv);

%% calculate third octave matrix
[TOL_band, TOL_m, TOL_low, TOL_high] = octaves;
%remove bands 1 to 9 and start with 10th band, i.e. 1/3 octave centered on 10 Hz
TOL_band(1:9) = [];
TOL_m(1:9) = [];
TOL_low(1:9) = [];
TOL_high(1:9) = [];

%% loop through LTSAs and set up hourly matrices to compute and write out
% ASSUMES 1s and 1Hz resolution

%!!!! insert case HARP and SoundTrap

for lIdx = 1:length(FileList)
    %set up data handling routine
    [x] = aves_setup_SoundTrap(dc, keep, block, PathFileList{lIdx},tf,TOL_low,...
        TOL_m,TOL_high,sensitivity,isec);
    
end
% 


mat_ffn = fullfile(outpath,sprintf('%s.mat',ofroot));
mat_ffn = cellstr(mat_ffn);
plotDailyAveSpectraByMonth_180417('PathFileList',mat_ffn,'pdir',pdir);

% ofroot = 'JAX_D_13_dailyAves_rmStrum_4Hz_25dB';
% % generate daily aves with strum removed at 5 Hz/20 dB re counts/Hz^2
% LTSAdailySpectraStrumDt_180416(navepd_cont, dc, outpath, ofroot, dftf_file,...
%     rm_fifo, tres,'strumDT', [ fbin, sthr ], 'PathFileList', PathFileList, 'harp_tf', harp_tf);
% 
% mat_ffn = fullfile(outpath,sprintf('%s.mat',ofroot));
% mat_ffn = cellstr(mat_ffn);
% plotDailyAveSpectraByMonth_180417('PathFileList',mat_ffn,'pdir',pdir);
