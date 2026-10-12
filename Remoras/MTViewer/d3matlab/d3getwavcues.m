function    [BLKS,fs,fn,recdir,id] = d3getwavcues(recdir,prefix,suffix)
%    [BLKS,fs,fn,recdir,id] = d3getwavcues(recdir,prefix,suffix)
%     Forms a cue table from a sequence of D3 WAV-format files with
%     names like recdir/prefixnnn.suffix, where nnn is a 3 digit number.
%     Suffix can be 'wav' (the default) or 'swv' or any other suffix
%     assigned to a wav-format configuration.
%
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013

BLKS= [] ; fs = [] ; fn = [] ; id = [] ;

if nargin<3 | isempty(suffix),
   suffix = 'wav' ;
end

% get file names
[fn,did,recn,recdir] = getrecfnames(recdir,prefix) ;
if isempty(fn), 
   recdir = [] ; 
   return
end

% read in xml data for each output file and assemble a cue table
for k=1:length(fn),
   d3 = readd3xml([recdir fn{k} '.xml']) ;
   if isempty(d3),
      fprintf('Unable to find or read file %s.xml\n', fn{k});
      return
   end
   
   % find the sampling rate if we don't already know it
   if isempty(fs),
      [fs fsne] = getfs(d3,suffix) ;
      id = getxmldevid(d3) ;
   end

   % find  WAVBLK entries with the correct suffix
   blks = getwavblks(d3,suffix) ;

   % if a corresponding WAV file exists, check the sample count and rate
   fname = [recdir fn{k} '.' suffix] ;
   if ~exist(fname,'file'),
      fprintf(' No %s file found for recording %s, skipping\n',suffix,fn{k}) ;
   else
      [s,fss] = wavread16(fname,'size') ;
      if(fsne~=fss(1))
         fprintf(' Warning: Sampling rate mismatch in recording %s\n',fn{k}) ;
      end
      if ~isempty(blks),
         if s(1)~=sum(blks(:,3)),
            fprintf(' Warning: Sample count mismatch in recording %s\n',fn{k}) ;
         end
      else
         % d3 xml files made with an old d3read don't have WAVBLK fields
         fprintf(' Warning: no WAVBLK fields - check version of d3read and re-run\n') ;
         t = getcuetime(d3,suffix) ;
         blks = [t s(1)] ;
      end
   end
   BLKS = [BLKS;repmat(k,size(blks,1),1) blks] ;
end

if isempty(fs),
   fprintf(' Warning: Unable to determine sampling rate for this configuration\n');
   return ;
end

% check the timing
tdur = diff(BLKS(:,2)-BLKS(1,2)+(BLKS(:,3)-BLKS(1,3))*1e-6) ;
sdur = BLKS(1:end-1,4)/fs ;
terr = tdur-sdur ;
se = round(terr*fs) ;
k = find(abs(se)>1) ;
if ~isempty(k),
   fprintf(' Warning: Timing errors found - check version of d3read and rerun\n') ;
   for kk=k',
      fprintf(' => time error in file %s of %3.3f seconds (%d samples)\n',...
         fn{BLKS(kk,1)},terr(kk),se(kk)) ;
   end
   % fix timing errors
   for k=2:size(BLKS,1),
      tdiff = BLKS(k,2)-BLKS(k-1,2)+(BLKS(k,3)-BLKS(k-1,3))*1e-6 ;
      BLKS(k,3) = BLKS(k,3)-1e6*(tdiff-BLKS(k-1,4)/fs) ;
   end
end
return


function    [fs,fsne,k] = getfs(d3,suffix)
%
%
fs = [] ;
if ~isfield(d3,'CFG'),
   return
end

for k=1:length(d3.CFG),
   c = d3.CFG{k} ;
   if ~isfield(c,'FTYPE'), continue, end
   if ~strcmp(c.FTYPE,'wav'), continue, end
   if ~isfield(c,'SUFFIX'), continue, end
   if ~strncmp(c.SUFFIX,suffix,length(suffix)), continue, end
   if ~isfield(c,'FS'), continue, end
   if isfield(c,'EXP'),
      c.EXP(c.EXP=='_') = '-' ;     % reverse the fix in readd3xml to overcome Matlab
                                    % field name restrictions
      expn = str2double(c.EXP) ;
   else
      expn = 0 ;
   end
   fsne = str2double(c.FS) ;
   fs = fsne * 10^expn ;
   break ;
end
return


function    blks = getwavblks(d3,suffix)
%
%
blks = [] ;
if ~isfield(d3,'WAVBLK'),
   return
end

for k=1:length(d3.WAVBLK),
   c = d3.WAVBLK{k} ;
   if ~isfield(c,'SUFFIX'), continue, end
   if ~strcmp(c.SUFFIX,suffix), continue, end
   if ~isfield(c,'RTIME') | ~isfield(c,'MTICKS') | ~isfield(c,'NSAMPS'), continue, end
   blks(end+1,:) = str2double({c.RTIME;c.MTICKS;c.NSAMPS}) ;
end
return


function    t = getcuetime(d3,suffix)
%
%
t = [] ;
if ~isfield(d3,'CUE'),
   return
end

if isstruct(d3.CUE)
   d3.CUE = {d3.CUE} ;
end

for k=1:length(d3.CUE),
   c = d3.CUE{k} ;
   if ~isfield(c,'SUFFIX'), continue, end
   if ~strcmp(c.SUFFIX,suffix), continue, end
   if ~isfield(c,'TIME') | ~isfield(c,'CUE'), continue, end
   t(1) = d3datenum(sscanf(c.TIME,'%d,',6)') ;
   t(2) = str2double(c.CUE)*1e6 ;
   return
end

return
