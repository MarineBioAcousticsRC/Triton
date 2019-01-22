function [Weights, Alpha, Beta, InClass, OutOfClass] = stOptimalLDAWeights(Score, varargin)
% [Weights, Alpha, Beta, InClass, OutOfClass] = ...
%	stOptimalLdAWeights(Score, Options...)
% In a recognition task where various feature sets have been used
% to score the same token, a recombination strategy must be selected.
%
% In this function, a set of scores for each class are passed in as a cell
% array.  Each cell element is an FxCxT matrix where F represents a
% particular feature set, C the class index, and T the indvidual tokens for
% which each feature/class specific model(F,C) was tested.  
%
% It is assumed that each cell of the Score cell array is of the same size 
% with the exception of the number of tokens.
%
% Options:
%	'Classes' Vector - Generate LDA weights based only upon the
%			data in Scores{Classes}.  Allows LDA
%			to be generated for a specific class or set
%			of classes.
%	'Display'	- Generate a plot (only valid for 3 component
%			data

error(nargchk(1,inf,nargin))

ClassCount = length(Score);
ClassLabels = 1:ClassCount;
FeatureCountP = size(Score{1}, 1);
TokenCounts = zeros(ClassCount, 1);
LDAClasses = 1:ClassCount;
Display=0;

m=1;
while m <= length(varargin)
  switch varargin{m}
    case 'Classes'	% generate LDA for specific classes
      LDAClasses = varargin{m+1};
      if size(LDAClasses, 1) > 1
	LDAClasses = LDAClasses';	% make row vector
      end
      m=m+2;
    case 'Display'
      Display = 1;
      m=m+1;
    otherwise
      error(sprintf('Bad option "%s"', varargin{m}));
  end
end

for c=1:ClassCount
  TokenCounts(c) = size(Score{c}, 3);
  if (size(Score{c}, 1) ~= FeatureCountP | size(Score{c}, 2) ~= ClassCount)
    error(sprintf('Speaker %d has invalid size Score matrix', c))
  end
end
TokenCount = sum(TokenCounts);
  
FeatureCount = FeatureCountP - 1;
FeatureRange = 1:FeatureCountP;
Classes = 1:ClassCount;

% Separate all in-class out-of-class scores
InClass = [];
OutOfClass = [];
for c=LDAClasses
  OutOfClassIdx = Classes;
  OutOfClassIdx(c) = [];		% Remove current class

 
  
  %F x C x T
  % Append the test cases for in class scores in a Feature x Test matrix
  InClass = [InClass; ...
    squeeze(Score{c}(FeatureRange,c,:))'];
    
  % Append out of class scores in a Feature x Test matrix
  % Select Feature x OutOfClass x Test from Score matrix 
  % then reshape into Feature x Test where all OutOfClass
  % measurements are merged
  OutOfClass = [OutOfClass; ...
    reshape(Score{c}(:,OutOfClassIdx,:), ...
	FeatureCountP, length(OutOfClassIdx) * TokenCounts(c))' ...
	];

  % Remove any entries which were not scored
  [DelRows, Dummy] = find(InClass == -Inf);
  InClass(DelRows,:) = [];

  [DelRows, Dummy] = find(OutOfClass == -Inf);
  OutOfClass(DelRows,:) = [];

end  

InClass(:,FeatureCountP) = [];		% delete combined score
OutOfClass(:,FeatureCountP) = [];

[Weights, Alpha, Beta] = lda(InClass, OutOfClass);

if Display
  newplot
  axis off
  HoldState = ishold;
  axes('position', [.1, .8, .2, .15])
  plot(OutOfClass(:,1), OutOfClass(:,2), 'r.');
  hold on
  plot(InClass(:,1), InClass(:,2), 'g+');
  xlabel('b1');
  ylabel('b2');

  axes('position', [.4, .8, .2, .15])
  plot(OutOfClass(:,2), OutOfClass(:,3), 'r.');
  hold on
  plot(InClass(:,2), InClass(:,3), 'g+');
  xlabel('b2');
  ylabel('b3');

  
  axes('position', [.7, .8, .2, .15])
  plot(OutOfClass(:,1), OutOfClass(:,3), 'r.')
  hold on
  plot(InClass(:,1), InClass(:,3), 'g+')
  xlabel('b1')
  ylabel('b3')
  
  axes('position', [.1, .1, .8, .6])
  plot3(OutOfClass(:,1), OutOfClass(:,2), OutOfClass(:,3), 'r.')
  hold on
  plot3(InClass(:,1), InClass(:,2), InClass(:,3), 'g+')
  axis vis3d
  rotate3d on
  xlabel('b1')
  ylabel('b2')
  zlabel('b3')
  

  if ~ HoldState
    hold off
  end
end


