function    readmatxml(xmlfile)
%    readmatxml(xmlfile)
%     Read a MbML format xml file. This is a front-end
%     for the xml2mat function in the XML4MATv2 toolbox
%     available on the Mathworks user contributed website.
%     Make sure that toolbox is on your matlab path before
%     using this function.
%
%     mark johnson
%     25 march 2012

[rx,vname]=xml2mat(xmlfile);
if isempty(vname),
   fprintf('Unable to read %s\n',xmlfile) ;
   return
end

assignin('caller',vname,rx) ;
