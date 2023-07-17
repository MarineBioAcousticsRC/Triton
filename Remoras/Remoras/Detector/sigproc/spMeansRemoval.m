function DataNoMeans = spMeansRemoval(Data, Window, Components)
% DataNoMeans = spMeansRemoval(Data, Window, Components)
% Removes the mean of a set of data.  Data is assumed to be a maxtrix where
% each row represents one observation.  DataNoMeans contains the mean
% corrected data.
%
% The optional argument Window indicates that a running mean of Window 
% frames should be used.  If Window is not odd, it will be decreased by
% one to make it so.
%
% The optional vector Components specifies that means removal should
% only be computed for a subset of the components specified in the
% vector.  As an alternative to omitting Components, one may use the
% empty matrix [] to specify all components.
%
% This code is copyrighted 1997, 1998 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

error(nargchk(1,3,nargin));

if nargin < 2
  Window = 0;
end

% Determine which components should have means removed.
% AllComponents indicates that all components will be smoothed and will
% permit an optimization later.
if nargin < 3
  Components = 1:size(Data,2);	% set default
  AllComponents = 1;
else 
  if isempty(setdiff(1:size(Data,2), Components))
    AllComponents = 1;
  else
    AllComponents = 0;
  end
end
  
if Window
  % Moving average filter (MA)
  
  if ~ mod(Window, 2)
    Window = Window - 1;	% insure odd
  end
  
  % Pad both sides by reflecting about the first and last data points
  % enough samples for the MA filter.  (Prevents edges from magnitude
  % reduction by including zeros in average).
  Pad = (Window - 1) / 2;
  mu = filter(1/Window * ones(Window,1), 1, ...
      [Data(Pad+1:-1:2,Components); ...
	Data(:,Components); ...
	Data(end-1:-1:end-Pad,Components)]);
      
  if AllComponents
    DataNoMeans = Data - mu(Window:end,:);
  else
    DataNoMeans = Data;
    MeanIdx = 1;
    for k = Components
      DataNoMeans(:,k) = DataNoMeans(:,k) - mu(Window:end,MeanIdx);
      MeanIdx = MeanIdx+1;
    end
  end

else
  % Global mean subtraction
  mu = mean(Data);
  if AllComponents
    DataNoMeans = Data - mu(ones(size(Data,1),1), :);
  else
    DataNoMeans = Data;
    for k = Components
      DataNoMeans(:,k) = DataNoMeans(:,k) - mu(ones(size(Data,1),1), k);
    end
  end

end


