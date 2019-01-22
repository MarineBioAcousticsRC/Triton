function [Filetype, FileExt] = ioGetFileType(Filenames)
%[Filetype, FileExt] = ioGetFileType(Filenames)
% Given a cell array of filenames, determine the filetype for each file
% and return them as an array along with their extension

if ischar(Filenames)
    Filenames = {Filenames};
end

if size(Filenames, 1) > 1
    Filenames = Filenames';
end

Filetype = zeros(size(Filenames));
FileExt = cell(size(Filenames));

% Determine file type
% Since filetypes extensions may be a subset of one another
% they are arranged from longest to shortest.  We search for
% the longest ones first and don't change the file type if
% we have a subsequent match.

ExtensionsBy_ftype = {'\.wav$', '\.x\.wav$'};
% Determine file type
tidx = length(ExtensionsBy_ftype);
while tidx > 0 
  % search for matches
  [ext, ofType] = regexpi(Filenames, ExtensionsBy_ftype{tidx}, ...
      'match', 'once');
  % indicator function for matches of this type
  extmatches = ~ cellfun('isempty', ofType);
  % indicatorfunction for matches that haven't already been set
  % in a previous iteration
  extset = extmatches & ~Filetype;
  Filetype(extset) = tidx(ones(1,sum(extset)));
  FileExt(extset) = ext(extset);
  tidx = tidx - 1;
end

