function documents = dbDetectionsForUser(queries, User)
% documents = dbUserDocuments(User)
% Return a list of documents submitted by the specified user

error(nargchk(2,2,nargin));

query = fullfile(fileparts(mfilename('fullpath')), 'xquery', 'UserEffort.xqr');
documents = dbRunQueryFile(queries, query, 'FormatQuery', {User});
