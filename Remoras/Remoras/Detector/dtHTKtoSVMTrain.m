function data = dtHTKtoSVM(Files, UseDays, Mu, Sigma)
% Read in HTK data and put in format for Torch
% Files is a cell array of all
% directory/directories which should be searched.  Pattern is the mask
% for matching the appropriate files.
% UseDays is a vector indicating which sequence of days to use
% for each species, e.g. [1 2] would use the first and second sequential
% days of data.
% 
% If Mu and Sigma are provided, data are normalized to z-scores.
%
% Note that ioWriteBin can be used to write the data in Torch
% SVM format.

if isempty(Files)
  data = [];
else
  
  if nargin < 4
    Mu = [];
    Sigma = [];

    if nargin < 3
      UseDays = 1:3;      % Hardcoded DCMMPA2007 dependent - yuck
    end
  
  % sort by date, last format is everything we know
  DateFormats = datepatterns();
  dates = dateregexp(Files, DateFormats{end});
  [dates sortidx] = sort(dates);
  Files = Files(sortidx);
  Days = cellstr(datestr(dates, 26));
  
  % Assume species is first directory.
  Species = cell(size(Files));
  for s=1:length(Species)
    % WARNING:  DCMMPA2007 dependent
    pat = regexp(Files{s}, '[/\\]?(.*[/\\])*_Data[/\\](?<species>[^/\\]+)[/\\].*', 'names');
    if isempty(pat)
      error('cannot find species')
    else
      Species{s} = pat.species;
    end
  end
  
  SpeciesList = unique(Species);
  SpeciesN = length(SpeciesList);
  ClassLabels = 0:SpeciesN-1;
  
  % Find information for each species.
  for s = 1:SpeciesN
    % files associate with this species
    Species_sidx = find(strcmp(Species, SpeciesList{s}));  
    % Break up by day.
    % find indices of days associated with this species
    DatesSpecies_s = Days(Species_sidx); 
    % find which days recordings cover
    DatesRecorded = unique(DatesSpecies_s);

    FileSpecies_s{s} = cell(size(DatesRecorded));
    for d = 1:length(DatesRecorded)
      DatesRecorded{d};
      dDay = find(strcmp(DatesSpecies_s, DatesRecorded{d}));
      FilesSpecies_s{d} = Files(Species_sidx(dDay));
    end
    FilesBySpeciesDay{s} = FilesSpecies_s;
  end
  
  % Read in data for each species for days we want to use
  % and assemble it into a large matrix with the class
  % appended.  


  data = [];
  for s = 1:SpeciesN
    class = ClassLabels(s);
    for d = 1:length(FilesBySpeciesDay{s})
      if ismember(d, UseDays)
        for ses = 1:length(FilesBySpeciesDay{s}{d})
          % Returns column oriented data, transpose to row oriented
          SessionData = ...
              spReadFeatureDataHTK(FilesBySpeciesDay{s}{d}{ses})';
          if ~ isempty(Mu)
            % transform to z-score
            SessionData = (SessionData - Mu) ./ ...
                Sigma(:, ones(size(SessionData,1), 1)); 
          end
          data = [data; [SessionData class*ones(size(SessionData,1),1)]];
        end
      end % if ismember
    end % for d
  end % for s
end % if isempty/else
