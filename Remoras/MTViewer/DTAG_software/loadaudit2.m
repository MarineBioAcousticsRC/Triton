function    R=loadaudit2(tag)
%
%    R=loadaudit2(tag)
%     read an audit CSV file with name fname into an audit structure.
%     The CSV file contains lines of the form:
%        cue duration type comment
%     defined by the form auditform.m
%
%     Output:
%        R is a structure containing the audit cues, types and
%        comments.
%        Use findaudit, showaudit, tagaudit and saveaudit to handle R.
%     
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: August 2008

if nargin<1,
   help loadaudit2
   return
end

% try to make filename
global TAG_PATHS
if ~isempty(TAG_PATHS) & isfield(TAG_PATHS,'AUDIT'),
   fname = sprintf('%s/%saud.csv',TAG_PATHS.AUDIT,tag) ;
else
   fname = sprintf('%saud.csv',tag) ;
end

% check if the file exists
if ~exist(fname,'file'),
   fprintf(' Unable to find audit file %s - check directory and settagpath\n',fname) ;
   return
end

% read in audit form
F = auditform ;

% read the CSV file
[X,fields] = readcsv(fname) ;
R = parsecsv(F,X) ;
