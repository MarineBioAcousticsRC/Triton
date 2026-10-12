function    [fnames,ochips,ndigits] = makefnames(tag,type,chips)
%
%    [fnames,ochips,ndigits] = makefnames(tag,type,chips)
%     Look for files of a particular type but with different chip suffixes.
%     Returns a cell array of filenames.
%     chips may be empty indicating to look for all chips with the
%     correct tag name.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     October, 2007

if nargin<2,
   help makefnames
   return
end

ndigits = 2 ;
MAXCHIPS = 244 ;
if nargin==2 | isempty(chips),
   SEARCH = 1 ;
   chips = 011:MAXCHIPS ; % temporarily changing this to accomodate zc10_272a. 10/2025 Ainsleigh Lloyd
else
   SEARCH = 0 ;
end

fnames = {} ; ochips = [] ;
for k=chips(:)',
   if k>0 & k<=MAXCHIPS,
      fn = makefname(tag,type,k,[],2) ;
      if ~isempty(fn) & ~isstr(fn),
         break ;
      end

      if exist(fn,'file'),
         fnames{length(fnames)+1} = fn ;
         ochips = [ochips;k] ;
         continue
      end
      % try a 3-digit file number
      fn = makefname(tag,type,k,[],3) ;
      if exist(fn,'file'),
         fnames{length(fnames)+1} = fn ;
         ochips = [ochips;k] ;
         ndigits = 3 ;
         continue
      end

      if SEARCH==0,
         fprintf(' Unable to find a file with name %s, skipping\n', fn) ;
      end
   else
      fprintf(' Bad chip number %03d in chip list - skipping\n', k) ;
   end
end
return
