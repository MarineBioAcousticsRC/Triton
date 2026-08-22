function params = dtParseParameterSet(varargin)
% params = dtParseParameterSet(varargin)
% Parse 'ParameterSet' optional arguments.  If the user has not specified
% a parameter set, the default set is used.
% varargin should be a list of keyword/value pairs and we look for:
%   'ParameterSet', String or struct
%       Default set of parameters.  May either be a string
%       which is used to read a specific set of parameters or it may
%       contain a structure of current parameters.  In either case,
%       the parameters are returned.


ParameterSetIdx = [];
ParameterSet = 'odontocete';  % default

if length(varargin) > 0
    % Find last index of ParameterSet string
    ParameterSetIdx = find(strcmp('ParameterSet', varargin(1:2:end)), 1, 'last');
end
if ~ isempty(ParameterSetIdx)
    % User specified a parameter set, override the default.
    vidx = ParameterSetIdx*2; % posn in keywords to posn in all args
    ParameterSet = varargin{vidx};
end
if ischar(ParameterSet)
    % Named set, retrieve it.
    params = dtThresh(ParameterSet);
elseif isstruct(ParameterSet)
    % Caller passed in a structure, return it and hope
    % they knew what they were doing...
    params = ParameterSet;
else
    error('Bad ParameterSet');
end