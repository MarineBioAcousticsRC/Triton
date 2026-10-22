function    writematxml(v,vname,xmlfile)
%    writematxml(v,vname,xmlfile)
%     Write a MbML format xml file. This is a front-end
%     for the mat2xml function in the XML4MATv2 toolbox
%     available on the Mathworks user contributed website.
%     Make sure that toolbox is on your matlab path before
%     using this function.
%
%     mark johnson
%     25 march 2012

xx=mat2xml(v,vname);
f=fopen(xmlfile,'wt');

% add carriage returns to the string so that it is legible
% if the file is read in a text editor
k=[0 findstr(xx,'><') length(xx)] ;
for kk=1:length(k)-1,
   fprintf(f,'%s\n',xx(k(kk)+1:k(kk+1))) ;
end
fclose(f);
