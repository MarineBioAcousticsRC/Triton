function dbStruct2DOM(s, append_to)
% dom = dbStruct2DOM(s, append_to)
% Given:
%   s - a Matlab structure
%   append_to - an DOM node
% append elements of s to append_to.  

import org.w3c.dom.Comment;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.*;

if ~ isa(s, 'struct')
    error('Expecting a structure');
end

factory = DocumentBuilderFactory.newInstance();
builder = factory.newDocumentBuilder();
doc = builder.newDocument();

add_elements(doc, append_to, s);

function add_elements(doc, dom, s)

fields = fieldnames(s);
for fidx = 1:length(fields)
    fname = fields{fidx};  % current field
    % Todo:  Massage field names to valid XML element name
    xmlname = fname;
    el = doc.createElement(xmlname); % addew node 
    if isa(s.(fname), 'struct')
        % Field is a structure. Handle recursively
        add_elements(doc, el, s.(fname));
    elseif isa(s.(fname), 'table') || isa(s.(fname), 'cell')
        error('tables and cell arrays are not yet supported');
    else
        % Assume either numeric or character array
        % Not a struct, 
        if isnumeric(s.(fname))|| islogical(s.(fname))
            val = mat2str(s.(fname));
        else
            val = s.(fname);
        end
        text = doc.createTextNode(val);
        el.appendChild(text);
    end
    % el contains the information for the current element & its children
    % Link it into the DOM or ArrayList
    if isa(dom, 'java.util.ArrayList')
        % Top level call, dom is a JAXB array
        if dom.add(el) ~= 1
            error('Unable to add element %s with value %s', xmlname, val);
        end
    else
        % This is a subelement, dom is a regular element
        dom.appendChild(el);
    end
    
end




