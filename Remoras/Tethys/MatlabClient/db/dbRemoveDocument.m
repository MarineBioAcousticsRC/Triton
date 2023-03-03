function result = dbRemoveDocument(query_h, collection, docName)
% result = dbRemoveDocument(query_h, collection, docName)
% Given a collection name, e.g. detections, deployments, etc., and a
% document name, remove the document.
%
% For collections that support an Id element, the docName is usually
% the same as the Id.  To see a list of document names in a collection,
% type server_name:port//CollectionName in a web browser.  For example,
% if the server is running on cetacea.us using the default port of 9779,
% use http://cetacea.us/Deployments to see the list of documents 
% in the Deployments collection.

doc = query_h.getDocument(collection, docName);
if doc.length == 0
    error('Tethys:EmptyDocument', 'No content for document %s in %s', ...
        docName, collection)
end

result = query_h.removeDocument(collection, docName);
