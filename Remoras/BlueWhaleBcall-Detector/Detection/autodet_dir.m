% autodet_dir

% Adapted from decimatexwav_dir
% smk 100219
% Updated to look for only xwavs and output to .xls (not .txt)
% smk 110603

%-------------------------------------------------------------------------
% Choose input directory.
ii = 1;
ddir = '';   % default directory
idir{ii} = uigetdir(ddir,['Select Directory of XWAVS']);
% if the cancel button is pushed, then no file is loaded so exit this script
if strcmp(num2str(idir{ii}),'0')
    disp('Canceled Button Pushed - no directory for XWAV inputs')
    return
else
    disp('Input file directory : ')
    disp([idir{ii}])
    disp(' ')
end

% Display number of files in directory
d = dir(idir{ii});    % directory info
fn = {d.name}';      % file names in directory
str = '.x.wav';
k = strfind(fn, str);
for m = 1:length(k)
    n(m,1) = isempty(k{m,1});
end
x = n == 0;
xwavs = fn(x);
xnum = size(xwavs);
numx = xnum(1);
disp(['Number of XWAVs in Input file directory is ',num2str(numx)])

%--------------------------------------------------------------------------
% Choose output file
boxTitle1 = ['Select Output Text File'];
filterSpec1 = '*.txt';
defaultName = 'E:';
[outfile,outpath]=uigetfile(filterSpec1,boxTitle1,defaultName);
outflen = length(outfile);
outplen = length(outpath);

% -------------------------------------------------------------------------
%Loop the following codes through chosen directory
detALL=[];
for jj = 1:numx
    directory.inpath = strcat(idir,'\');
    directory.infiledet = xwavs(jj,:); % get file names sequentally
    filename = strcat(directory.inpath,directory.infiledet);    
    disp(['Looking for calls in  ' filename{1,1}])
%     [fid,message] = fopen([xwavs.inpath,xwavs.infiledet], 'r');  %reading file    
    autodet([filename{1,1}], [outpath, outfile])
end



