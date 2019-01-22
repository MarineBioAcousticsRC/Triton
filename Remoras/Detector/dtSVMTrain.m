function [ndata, nstats] = dtSVMTrain(TrainingScript, Classes, normalize)
% [ndata, nstats] = dtSVMTrain(TrainingScript, Classes)
% Read in data and return one version of it for each class
% If normalize is present and true, each copy of the data
% is normalized by the mean and variance of that specific
% class.  Otherwise, the copies are identical.

ClassN = length(Classes);

if nargin < 3
  normalize = false;
end

% Load in the data
files = dtHTKScript(TrainingScript);
data = dtHTKtoSVM(files, Classes);

% Compute means/variances for each data set.
for c=1:ClassN
  % locate features for this class
  cidx = find(data(:,end) == c-1);
  % determine stats
  nstats(c).mu = mean(data(cidx,1:end-1));
  nstats(c).std = std(data(cidx,1:end-1));
end

% Normalize for each class
ndata = cell(ClassN, 1);
ClassLabels = data(:,end);
Features = 1:size(data, 2)-1;
Vectors = size(data, 1);
for c=1:ClassN
  if normalize
    ndata{c} = [(data(:,Features) - nstats(c).mu(ones(Vectors,1),:)) ./ ...
                nstats(c).std(ones(Vectors,1),:) ClassLabels];
  else
    ndata{c} = data;
  end
end
