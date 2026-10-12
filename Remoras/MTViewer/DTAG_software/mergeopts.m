function    OUTOPTS = mergeopts(INOPTS,DEFOPTS) 
%
%    OUTOPTS = mergeopts(OPTS1,OPTS2)
%     Merge the fields of two structures. If there are duplicate
%     fields, the fields in OPTS1 are taken.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     12-11-07

if nargin<2,
   help mergeopts
   return
end

% start with default settings
OUTOPTS = DEFOPTS ;

% overwrite with primary options
Z = fieldnames(INOPTS) ;
for k=1:length(Z),
   OUTOPTS = setfield(OUTOPTS,Z{k},getfield(INOPTS,Z{k})) ;
end
