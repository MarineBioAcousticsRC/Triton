function    OUTOPTS = resolveopts(tag,OPTS,INOPTS) 
%
%    OPTS = resolveopts(tag,OPTS,INOPTS)
%     Select options to pass to toolbox functions.
%     tag is the name of the deployment or just the two-letter
%     species identifier.
%     OPTS is a master structure of options containing default
%     fields and fields specific to species.
%     INOPTS is a user-defined set of options that are to be
%     amalgamated with OPTS to form the output.
%     Process is to (i) accept all fields in INOPTS, (ii) check
%     if any additional fields are specified for the species or
%     in the default section of OPTS. Priority order is: INOPTS,
%     species specific options, default options.
%
%     Warning: EXPERIMENTAL!!
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     12-11-07

if nargin<2,
   help resolveopts
   return
end

% start with default settings
OUTOPTS = OPTS.def ;

if isempty(INOPTS),
   INOPTS = struct ;
end

% overwrite with species specific settings
if isstr(tag) & length(tag>=2) & isfield(OPTS,tag(1:2)),
   Z = getfield(OPTS,tag(1:2)) ;
   Zn = fieldnames(Z) ;
   for k=1:length(Zn),
      OUTOPTS = setfield(OUTOPTS,Zn{k},getfield(Z,Zn{k})) ;
   end
end

if nargin<3,
   return
end

% overwrite with user options
Zn = fieldnames(INOPTS) ;
for k=1:length(Zn),
   OUTOPTS = setfield(OUTOPTS,Zn{k},getfield(INOPTS,Zn{k})) ;
end
