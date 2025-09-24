function users = dbGetUsers(queries)
% users = dbGetUsers(queries)
% Return a cell array with users that have detection effort.

error(nargchk(1,1,nargin));

query = fullfile(fileparts(mfilename('fullpath')), 'xquery', 'Users.xqr');
documents = dbRunQueryFile(queries, query);
tmp = textscan(documents, '%s'); % parse out lines
users = tmp{1};


