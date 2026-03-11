function calltypes = dbGetCalltypes(queryEng, MetaDataPred, DetectionPred)
% calltypes = dbGetCalltypes(queryEng, MetaDataPred, DetectionPred)
% Given a database query engine,
% Return a list of calltypes meeting the associated meta data
% and detection data predicates.
%
% Examples:  Return all call types for anthropogenic calls detected
% at sites M and N.
% dbGetCalltypes('Deployment/Site = "M" or Deployment/Site = "N"', ...
%       'Species = 'Anthro')

nargchk(2, 3, nargin);
if nargin < 3
  DetectionPred = '';
else
  DetectionPred = sprintf('[%s]', DetectionPred);
end
if nargin < 2
  MetaDataPred = '';
else
  MetaDataPred = sprintf('[%s]', MetaDataPred);
end

resultJava = queryEng.getDetectedCallTypes(MetaDataPred, DetectionPred);
resultMatlab = cell(resultJava);

linefeed = char(10);
if  ~ isempty(resultMatlab{1})
    result = textscan(resultMatlab{1}, '%s', 'delimiter', linefeed);
    calltypes = result{1};
else
    calltypes = [];
end

