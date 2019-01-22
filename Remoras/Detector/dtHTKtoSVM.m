function [data, featdist] = dtHTKtoSVM(Files, Patterns, Mu, Sigma)
% Read in HTK data and put in format for Torch
%
% Files is a cell array of strings containing entries from an HTK script file.
% Patterns is a cell array of strings containing regular expressions 
% that permit assignment to class based upon regular expression matching.
% Regular expressions contained in Patterns are tried in order.
% 
% If Mu and Sigma are provided, data are normalized to z-scores.
%
% Outputs:
% data - Matrix of feature vectors, one per row with last column
%        indicating class.
% 
% featdist - Number of features in each logical file (or physical
%            file if no logical file was specified) and the class
%            to which they have been assigned.
%
% Note that ioWriteBin can be used to write the data in Torch
% SVM format.

data = [];

if nargin < 4
  Mu = [];
  Sigma = [];
end

% Need to write two regexps as Matlab doesn't seem to handle nested
% groups ()
HTKScriptRE = '\s*(?<logical>[^=\s]+)=(?<physical>[^\[]*)';
HTKScriptRENum = '\s*(?<logical>[^=\s]+)=(?<physical>[^\[]*)\[(?<first>\d+),(?<last>\d+)\]';


ClassFirst = 0;
ClassOffset = 1 - ClassFirst;
CurrentFile = [];
featdist = [];
ClassN = length(Patterns);
for f = 1:length(Files)
    % Figure out what they want
    Class = ClassFirst;
    ClassFound = false;
    while ~ ClassFound && Class < ClassN - ClassFirst
      if ~ isempty(regexp(Files{f}, Patterns{Class+ClassOffset}))
        ClassFound = true;
      else
        Class = Class + 1;
      end
    end
    if ~ ClassFound
      warning('Unable to determine class: "%s"', Files{f})
      Class = ClassN + 1;
    end
    
    % Parse the script file -------------------------------------
    match = regexp(Files{f}, HTKScriptRENum, 'names');
    if isempty(match)
      match = regexp(Files{f}, HTKScriptRE, 'names');
      if isempty(match)
        match.physical = Files{f};
      end
    end
    
    % Is the desired file already loaded?  If not, load it...
    if ~ strcmp(CurrentFile, match.physical)
      % Returns column oriented data, transpose to row oriented
      physdata = spReadFeatureDataHTK(match.physical)';
    end
    
    % Use all of the data or only part of it?
    if isfield(match, 'first')
      % Add 1 due to Matlab indexing starting at 1
      Start = sscanf(match.first, '%d')+1;
      Stop = sscanf(match.last, '%d')+1;
      
      ClassCol = Class * ones(Stop-Start+1, 1);
      if ~ isempty(Mu)
        zdata = znorm(physdata(Start:Stop, :), Mu, Sigma);
        data = [data; [zdata, ClassCol]];
      else
        data = [data; [physdata(Start:Stop, :), ClassCol]];
      end
      featdist = [featdist; [Stop-Start+1, Class]];
    else
      ClassCol = Class * ones(size(physdata, 1));
      if ~ isempty(Mu)
        zdata = znorm(physdata, Mu, Sigma);
        data = [data; [zdata, ClassCol]];
      else
        data = [data; [physdata, ClassCol]];
      end
      featdist = [featdist; [size(physdata,1), Class]];
    end
end

function zdata = znorm(data, Mu, Sigma)

zdata = (data - Mu(ones(1, size(data,1)), :)) ./ ...
        Sigma(ones(1, size(data,1)), :);

