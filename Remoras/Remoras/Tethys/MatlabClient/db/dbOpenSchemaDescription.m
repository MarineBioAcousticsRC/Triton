function dbOpenSchemaDescription(query_eng, root_element)
% dbOpenSchemaDescription(query_eng, root_element)
% Given a query handle to a Tethys server and a root element,
% open a web page that describes the shema.
%
% Schema           Root element
% deployments      Deployment
% detections       Detections
% calibrations     Calibration
% localizations    Localize
% ensembles        Ensemble

url_base = query_eng.getURLString();
url =  sprintf('%s/Schema/%s?format=HTML', url_base, root_element);
    
web(url)
