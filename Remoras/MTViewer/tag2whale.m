function		[Aw,Mw] = tag2whale(A,M,OTAB,fs)
%
%		[Aw,Mw] = tag2whale(A,M,OTAB,fs)
%     Convert tag frame measurements to whales frame
%     using the tag orientation(s) in the OTAB.
%     Each row of OTAB is:
%        [cue1 cue2 pitch roll heading]
%     where cue1 is the start time of a move in seconds 
%     since tag on, cue2 is the end time of the move.
%     The angles describe the tag orientation on the whale
%     at the end of the move (angles are in radians).
%     For a sudden move, use cue2=cue1. For a fixed
%     orientation, not necessarily associated with a
%     move, use cue2=0. The first entry in OTAB must
%     have cue2=0 and represents the initial orientation
%     of the tag when first attached to the whale.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     Last modified: 29 June 2006

Aw = [] ; Mw = [] ;

if nargin<4,
   help tag2whale
   return
end

% first OTAB entry must be a fixed-point (i.e., cue2=0)
if OTAB(1,2) ~= 0,   
   fprintf(' First OTAB entry must be a position not a move\n') ;
   return
end

if size(OTAB,1)>1,

   PTAB = o2p(OTAB) ;
   t = (1:size(A,1))'/fs ;

   if PTAB(1,1) > t(1),
	   PTAB = [t(1) PTAB(1,2:4);PTAB] ;
   end

   if PTAB(end,1) < t(end),
	   PTAB = [PTAB;t(end) PTAB(end,2:4);] ;
   end
   prh = interp1(PTAB(:,1),PTAB(:,2:4),t) ;

else
   prh = OTAB(3:5) ;
end

% Now compute the whale frame A and M matrices:
[Aw,Mw] = rotateAM(A,M,prh) ;
return


function    PTAB = o2p(OTAB)
%
%
SMALL = 0.1 ;     % duration in seconds of the shortest move

% sort events into causal order
[pp I] = sort(OTAB(:,1)) ;
OTAB = OTAB(I,:) ;
n = size(OTAB,1) ;

% remove overlapping events
k = 1 ;
while k<size(OTAB,1),
   kk = find(OTAB(k,2)+SMALL<OTAB(k+1:end,1))' ;
   OTAB = OTAB([1:k k+kk],:) ;
   k = k+1 ;
end

if size(OTAB,1)<n,
   fprintf(' Overlapping events found in OTAB and removed\n') ;
end

% force sudden moves to have duration SMALL
k = find(OTAB(:,1) == OTAB(:,2)) ;
OTAB(k,2) = OTAB(k,1)+SMALL ;

% make PTAB
PTAB = OTAB(1,[1 3:5]) ;

for k=2:size(OTAB,1),
   if OTAB(k,2)>OTAB(k,1),
      PTAB = [PTAB; OTAB(k,1) PTAB(end,2:4)] ;
      PTAB = [PTAB; OTAB(k,2:5)] ;
   else
      PTAB = [PTAB; OTAB(k,[1 3:5])] ;
   end
end
return
