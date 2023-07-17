function filtered = filter_results(results, files);
% Given a result set and a list of wav files, return a new
% result set containing only those files.

rfiles = {results.file};
% Normalize filenames
rfiles = strrep(rfiles, '\', '/');
files = strrep(files, '\', '/');

% Look for files in result files
select = zeros(1, length(rfiles));
for idx=1:length(files)
    select = select | ~ cellfun(@isempty, strfind(rfiles, files{idx}));
end
filtered = results(select);


