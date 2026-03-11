function [dom, results] = dbXPathDomQuery(doc, query, nodereturn)
% Given a document object model representation of a document,
% run an XPath query on it
% nodereturn is an optional argument that controls the return type:
%  'node' --> XPathConstants.NODE
%  'nodeset' --> XPathConstants.NODESET (a sequence of nodes)


import javax.xml.xpath.*;
import dbxml.NamespaceContextMap;

if nargin > 2
    switch nodereturn
        case 'node'
            nodetype = XPathConstants.NODE;
        case 'nodeset'
            nodetype = XPathConstants.NODESET;
        otherwise
            error('bad nodereturn type')
    end
else
   nodetype = XPathConstants.NODESET; 
end

factory = XPathFactory.newInstance();
xpath = factory.newXPath();

namespaces = NamespaceContextMap('ty', 'http://tethys.sdsu.edu/schema/1.0');
xpath.setNamespaceContext(namespaces);
query_obj = xpath.compile(query);

dom = query_obj.evaluate(doc, nodetype);

if nargout > 1
    N = dom.getLength();
    results = cell(N, 1);
    if N > 0
        for k=0:N-1
            results{k+1} = char(dom.item(k).getTextContent());
        end
    else
        results = cell(1);
        end
end
