function query_text = dbGetCannedQuery(querynm)
% query_text = dbGetCannedQuery(query)
% Return a canned query with printf style strings
% to set criteria.
%
% Query are defined in the xqueries directory relative to this function

[directory, dontcare] = fileparts(mfilename('fullpath'));

fname = fullfile(directory, 'xqueries', querynm);

if exist(fname, 'file')
    % Read in the file
    query_textH = fopen(fname, 'r');
    query_text = fread(query_textH, Inf, 'uchar=>char')';
    fclose(query_textH);
    query_text = regexprep(query_text,'\r\n','\n'); %LF\CR -> LF
else
    % Show the user the error of their evil evil ways...
    valid = dir(fullfile(directory, 'xqueries', '*.xq'));
    if ~ isempty(valid)
        files = sprintf('Available files: %s', sprintf('%s ', valid.name));
    else
        files = 'No available files';
    end
    error('Unknown canned query. %s, %s.', files);
end

