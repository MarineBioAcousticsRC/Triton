function    [ct,ref_time,fs,fn,recdir] = d3getcues(recdir,prefix,suffix)
%
%    [ct,ref_time,fs,fn,recdir] = d3getcues(recdir,prefix,suffix)
%     Get the cue table, reference time, sampling rate and file information
%     for a D3 deployment.
%     ct has a row for each contiguous block in the deployment.
%     The columns of ct are:
%        Block number
%        Start time in seconds since the reference time
%        Number of samples in the block
%
%     markjohnson@st-andrews.ac.uk
%     bug fix: FHJ 8 april 2014

ct = [] ; ref_time = [] ; fs = [] ; fn = [] ;

if nargin<2,
   help d3getcues
   recdir = [] ;
   return
end

if nargin<3 | isempty(suffix),
   suffix = 'wav' ;
end

if ~isempty(recdir) & ~ismember(recdir(end),'/\'),
   recdir(end+1) = '/' ;
end

recdir(recdir=='\') = '/' ;      % use / for MAC compatibility

cuefname = [recdir '_' prefix suffix 'cues.mat'] ;
if ~exist(cuefname,'file')
   fprintf(' Generating cue file - will take a few seconds\n') ;
   cuefname = makecuefile(recdir,prefix,suffix) ;
end

if isempty(cuefname),
   fprintf(' Unable to make cue file\n') ;
   return
end

C = load(cuefname) ;
fs = C.fs ;
ct = C.cuetab ;
fn = C.fn ;
ref_time = C.ref_time ;
return
