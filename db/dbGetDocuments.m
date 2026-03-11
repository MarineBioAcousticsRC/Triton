function names = dbGetDocuments(queryEng,collection,varargin)

% function names = dbGetDocuments(queryEng,collection,varargin)
% Retrieve documents matching the criteria from the supplied collection.
% Input method has been copied directly from dbGetEffort and
% dbDeploymentInfo.
% 
% names is a cell array of strings containing either output filenames if an
% outpath was supplied using 'SaveTo', or a simply the document IDs as
% stored on Tethys.
%
% queryEng must be a Tethys database query object, see dbDemo() for an
% example of how to create one.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Shared Inputs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 'Project', string - Name of project data is associated with, e.g. SOCAL
% 'Site', string - name of location where data was collected
%
% Optional Inputs:
% 'ShowQuery', true|false (default)- Display the constructed XQuery
% 'PP', true|false (default) - Pretty print the output XML (slower)
% 'SaveTo', string - a directory to save the resulting XML files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%Detections Doc Inputs%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Skip ahead for Deployment documents...
% Detections documents are retrieved using inputs from dbGetEffort.
% 
%
% Attributes associate with project metadata:
% 'Cruise', comparison - Cruise associated with effort
% 'Deployment', comparison - Which deployment of sensor at a given location
% 'UserID', string - User that prepared data
% Attributes associated with how detections were made:
% 'Effort/Start'|'Effort/End', String - Specify start and or end of
%       detection effort.  Note that this is a direct comparison to the
%       effort start or end, not to the interval.  As an example,
%       effort between 2015-01-01T00:00:00Z and 2015-03-0112:00:00Z would
%       not be picked up if with Effort/Start, {'>=', '2015-02-01T00:00:00Z'}
%       as this is after the start of the deployment.
% 'Detector', string - Name of detector, e.g. human
% 'Version', string - What version of the detector
% 'Parameters', string - Parameters given to the detector, for humans,
%   we use the individual's user id.
% Attributes associated with species effort
% 'SpeciesID' - species/family/order/... name.  Format depends on the last
%    call to dbSpeciesFmt.  
% 'Call' - type of call
% 'Subtype' - subtype of call
% 'Group' - Species Group
% 'Granularity' - Type of effort
% 'BinSize_m' - Binsize in minutes
%
% Attributes whose argument is comparison can either be a:
%   scalar - queries for equality
%   cell array {operator, scalar} - Operator is a relational
%       operator in {'=', '<', '<=', '>', '>='} which is compared
%       to the specified scalar.
%
% One can also query for a specific document by using the document id
% in the detections collection:
% 'Document', DocID - DocId is 'dbxml:///Detections/document_name'
%     At the time of this writing, document names are derived from the 
%     source spreadsheet name.  Document names can also be obtained
%     from the results of this function, by inspecting the XML_Document
%     field of the Characteristics array.
%
%
%%%%%%%%%%%%%%%%%%%%%%%Deployment Doc Inputs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Equality checks:  Specified value must be equal (case independent)
% to the string provided
% 'Project', string - Name of project data is associated with, e.g. SOCAL
% 'Region', string
% 'Site', string - name of location where data was collected
%
% Floating point comparisions:  
% 'DeploymentID', Comparison - which deployment?
% 'DeploymentDetails/Latitude', Comparison
% 'DeploymentDetails/Longitude', Comparison
% 'DeploymentDetails/Depth_m', Comparison
% Comparison consists of either a:
%   scalar - queries for equality
%   cell array {operator, scalar} - Operator is a relational
%       operator in {'=', '<', '<=', '>', '>='} which is compared
%       to the specified scalar.
%






source = ''; % source string for xquery loop
outpath = ''; %default do not output
meta_conditions = '';  % selection criteria for detection meta data
det_conditions = '';  % selection criteria for detections
show_query = false; % do not display XQuery 
pretty = false; %do not pretty print output


% condition prefix/cojunction
% First time used contains where to form the where clause.
% On subsequent uses it is changed to the conjunction and
conj_meta = 'where';
conj_det = 'where';

%input error handling
if isempty(collection)
    error('Please input a collection to retrieve documents from')
end

idx=1;
%%Inputs for Detection Effort
if strcmp(collection,'Detections')
    while idx <= length(varargin)
        switch varargin{idx}
            case 'Document'
                comparison = dbListMemberOp('base-uri($detgroup)', varargin{idx+1});
                meta_conditions = sprintf('%s%s %s', ...
                    meta_conditions, conj_meta, comparison);
                conj_meta = ' and';
                idx = idx+2;
            case {'Method', 'Software', 'Version'}
                meta_conditions = ...
                    sprintf('%s%s upper-case($detgroup/Algorithm/%s) = upper-case("%s")', ...
                    meta_conditions, conj_meta, varargin{idx}, varargin{idx+1});
                conj_meta = ' and';
                idx = idx+2;
            case 'UserID'
                meta_conditions = sprintf('%s%s $detgroup/%s = "%s"', ...
                    meta_conditions, conj_meta, ...
                    varargin{idx}, varargin{idx+1});
                conj_meta = ' and';
                idx = idx+2;
                % DataSource details
            case {'Project', 'Site', 'Cruise'}
                field = sprintf('$detgroup/DataSource/%s', varargin{idx});
                meta_conditions = ...
                    sprintf('%s%s %s', ...
                    meta_conditions, conj_meta, dbListMemberOp(field, varargin{idx+1}));
                conj_meta = ' and';
                idx = idx+2;
            case { 'Effort/Start', 'Effort/End'}
                comparison = dbRelOp(varargin{idx}, ...
                    '$detgroup/%s', varargin{idx+1}, false);
                meta_conditions = sprintf('%s%s %s', ...
                    meta_conditions, conj_meta, comparison);
                conj_meta = ' and';
                idx = idx+2;
            case 'Deployment'
                comparison = dbRelOp(varargin{idx}, '$detgroup/DataSource/%s', varargin{idx+1});
                meta_conditions = sprintf('%s%s %s', ...
                    meta_conditions, conj_meta, comparison);
                conj_meta = ' and';
                idx = idx+2;
            case 'SpeciesID'
                % Build up list of possible species ids
                if ~ iscell(varargin{idx+1})
                    varargin{idx+1} = {varargin{idx+1}};
                end
                % Add fns to translate to TSN from current format
                varargin{idx+1} = cellfun(@(x) ...
                    sprintf(dbSpeciesFmt('GetInput'), x), varargin{idx+1}, ...
                    'UniformOutput', false);
                comparison = dbListMemberOp(...
                    sprintf('$k/%s', varargin{idx}), varargin{idx+1}, false);
                det_conditions = sprintf('%s%s %s', ...
                    det_conditions, conj_det, comparison);
                conj_det = ' and';
                idx = idx + 2;
            case {'Call', 'Granularity', 'Group', 'Subtype'},
                switch varargin{idx}
                    case 'Subtype'
                        % Call Subtype is part of parameters
                        varargin{idx} = 'Parameters/Subtype';
                    case 'Group'
                        % Group is an attribute of SpeciesID
                        varargin{idx} = 'SpeciesID/@Group';
                end
                comparison = dbListMemberOp(...
                    sprintf('$k/%s', varargin{idx}), varargin{idx+1});
                det_conditions = ...
                    sprintf('%s%s %s', det_conditions, conj_det, comparison);
                conj_det = ' and';
                idx = idx + 2;
            case 'BinSize_m'
                det_conditions = ...
                    sprintf('%s%s %s', ...
                    det_conditions, conj_det, ...
                    dbRelOp(varargin{idx}, '$k/Granularity/@BinSize_m', ...
                    varargin{idx+1}));
                conj_det = ' and';
                idx = idx + 2;
            case 'ShowQuery'
                show_query = varargin{idx+1};
                idx = idx+2;
            case 'SaveTo'
                outpath = varargin{idx+1};
                idx = idx+2;
            case 'PP'
                pretty = true;
                idx = idx+2;
            otherwise
                error('Bad arugment:  %s', varargin{idx});
        end
    end
    
% Inputs for Deployments
elseif strcmp(collection,'Deployments')
    while idx < length(varargin)
        switch varargin{idx}
            % Deployment details
            case {'Project', 'Region', 'Site'}
                meta_conditions = ...
                    sprintf('%s%s %s', meta_conditions, conj_meta, ...
                    dbListMemberOp(...
                    sprintf('$doc/%s', varargin{idx}), ...
                    varargin{idx+1}));
                conj_meta = ' and';
                idx = idx+2;
            case {'DeploymentID', 'DeploymentDetails/Latitude', ...
                    'DeploymentDetails/Longitude', 'DeploymentDetails/DepthInstrument_m'}
                comparison = dbRelOp(varargin{idx}, ...
                    '$doc/%s', varargin{idx+1});
                meta_conditions = sprintf('%s%s %s', ...
                    meta_conditions, conj_meta, comparison);
                conj_meta = ' and';
                idx = idx+2;
            case {'DeploymentDetails/TimeStamp'}
                comparison = dbRelOpChar(varargin{idx}, ...
                    '$doc/%s', varargin{idx+1});
                meta_conditions = sprintf('%s%s %s', ...
                    meta_conditions, conj_meta, comparison);
                conj_meta = ' and';
                idx = idx+2;
            case 'SaveTo'
                outpath = varargin{idx+1};
                idx = idx+2;
            case 'ShowQuery'
                show_query = varargin{idx+1};
                idx = idx+2;
            case 'PP'
                pretty = true;
                idx = idx+2;
            otherwise
                error('Bad argument %s', varargin{idx});
        end
    end
else
    error('Collection: %s is not found or supported', collection);
end








switch collection
    case 'Detections'
        query_str = dbGetCannedQuery('GetDetectionDocuments.xq');
        source = 'collection("Detections")/ty:Detections';
        query = sprintf(query_str, source, meta_conditions, det_conditions);
    case 'Deployments'
        query_str = dbGetCannedQuery('GetDeploymentDocuments.xq');
        source = 'collection("Deployments")/ty:Deployment';
        query = sprintf(query_str, source, meta_conditions);
    case 'Localizations'
        %unfinished
end

% Display XQuery
if show_query
    fprintf(query);
end

%Execute query
dom = queryEng.QueryReturnDoc(query);

tree = xml_read(dom);
uris = tree.URI';

if ischar(uris)
    %when theres only one matching URI
    %a char array is returned instead of cell    
    uris = uris'
    uris = {uris}
end    



names = cell(size(uris));
tic
for i=1:length(uris)
    [pathstr,name] = fileparts(uris{i});
    if ~isempty(outpath) %only query and output if Save option is used
        out_file = strcat(name,'.xml');
        names{i} = out_file;
        %this is where we use the xquery:
        doc = queryEng.QueryTethys(sprintf('for $d in collection("%s") where base-uri($d) = "%s" return $d',collection, uris{i}));
        
        fprintf('Outputting file: %s... ',out_file);
        if pretty
            doc = queryEng.xmlpp(doc);
        end
        %convert this from a Java string into a Matlab char string
        doc = char(doc);
        
        %the doc variable contains the document corresponding to names{idx}, we need to export it...
        %first, specify the output file location. this line will give it the same name as it exists on Tethys.
        %make sure to use double backslashes, and leave %s.xml at the end
        fullfilepath= fullfile(outpath,out_file);
        file_id = fopen(fullfilepath,'w');
        
        %we now print this document to the file, and close the file
        fwrite(file_id,doc);
        fclose(file_id);
        fprintf('done\n');
    else
        names{i} = name;
    end
    
end
toc



