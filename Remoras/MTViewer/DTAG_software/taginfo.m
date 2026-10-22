function    ss = taginfo(tag)
%
%     ss=taginfo(tag)
%     Print useful information on a tag deployment
%     tag is the standard deployment name e.g., 'md05_287a'
%
%     Make sure the paths to tag data have been declared
%     using settagpath.m
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     Last modified: 13 May 2006

if nargin<1,
   help taginfo
   return
end

[c t s ttype fs id] = tagcue(tag) ;
if isempty(c),
   return
end

t=datevec(datenum(t)) ;
fprintf('\n Deployment %s, tag %d, tag type %d\n', tag, id, ttype) ;
fprintf(' Tag started recording at: %d-%02d-%02d %02d:%02d:%02.1f\n', t) ;
fprintf(' Audio sampling rate %d kHz\n',...
   round(fs(1)/1000)) ;

% see if there are any wav files for this tag
for k=1:24,
   wfile = makefname(tag,'AUDIO',k) ;
   if isempty(wfile) | wfile(1)<0,
      return
   end
   if exist(wfile,'file'),
      break ;
   end
end

if exist(wfile,'file'),
   [y,afs,nbits,info] = wavread16(wfile,'size') ;
   fprintf(' Audio on %d channel(s)\n', info.fmt.nChannels) ;
   if isfield(info,'info'),
      info = info.info ;
      if isfield(info,'sens'),
         sens = info.sens ;
         fprintf(' Sensitivity: %s dB re V/uPa\n', sens) ;
      end
   end
else
   fprintf(' Unable to find wav files with names like %s##\n', wfile(1:end-6)) ;
   fprintf(' - check directory and use settagpath(''AUDIO'',...)\n') ;
end

fprintf(' Raw sensor sampling rate %2.2f Hz\n',fs(2)) ;
r = loadprh(tag,0,'fs') ;
if r==0,
   fprintf(' No prh file available for this tag\n') ;
else
   fprintf(' PRH file sampling rate %2.2f Hz\n',fs) ;
end
fprintf('\n')
