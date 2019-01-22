function [ndata featdist] = dtSVMTest(TestScript, Classes, nstats)
% ndata = dtSVMTest(TestScript, Classes, NormData)

if nargin < 3
  nstats = [];
end

ClassN = length(Classes);

% Load in the data
files = dtHTKScript(TestScript);
[data, featdist] = dtHTKtoSVM(files, Classes);

ClassLabels = data(:,end);
Features = 1:size(data, 2)-1;
Vectors = size(data, 1);

% Normalize for each class
if isempty(nstats)
  for c=1:ClassN
    ndata{c} = data;    % No normalization data, just copy
  end
else
  for c=1:length(nstats)
    ndata{c} = [(data(:,Features) - nstats(c).mu(ones(Vectors,1),:)) ./ ...
                nstats(c).std(ones(Vectors,1),:) ClassLabels];
  end
end

    



