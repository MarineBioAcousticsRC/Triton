function dbDeployments2kml(query_h, kmlfile, varargin)
% dbDeployments2kml(query_h, kmlfile, Optional Args)
% Write a KML file with all deployments meeting the criteria
% and display them in Google Earth.  
% 
% See dbDeploymentInfo() for optional arguments, the same arguments
% are supported and permit selection criteria for deployments.
%
% The additional keyword arguments can be used, but they must
% occur BEFORE dbDeploymentInfo keywords.
%
% 'First' true|false (default) - Show the first deployment only at any 
%   given site.  Useful for generating maps when there are many 
%   deployments.
% 'Timestamp', true(default) | false - Generate information about the 
%   deployment duration.
% 'Display', true| false(default) - Display generated map (requires
%   Google Earth
%
% Example:
% q = dbInit();  % set up query handler
%
% Show all deployments associated with project SOCAL
% dbDeployments2kml(q, 'socal.kml', 'Project', 'SOCAL');
% or
% Show the first deployment at each site associated with project SOCAL
% dbDeployments2kml(q, 'socal.kml', 'First', true, 'Timestamp', false, ...
%   'Project', 'SOCAL');

narginchk(2, Inf);

if ~ strcmp(which('kml'), '') == 0
    error('kml toolbox required:  http://www.mathworks.com/matlabcentral/fileexchange/34694-kml-toolbox-v2-6')
end    

Display = false;
First = false;
Timestamp = true;

vidx = 1;
more = vidx <= length(varargin);
while more
    switch varargin{vidx}
        case 'First'
            First = varargin{vidx+1}; vidx = vidx + 2;
        case 'Timestamp'
            Timestamp = varargin{vidx+1}; vidx = vidx + 2;
        case 'Display'
            Display = varargin{vidx+1}; vidx = vidx + 2;
        otherwise
            % Assume arguments for dbDeploymentInfo
            if vidx > 1
                varargin(1:vidx-1) = [];  % Remove consumed args
            end
            more = false;
    end
    more = more && vidx <= length(varargin);        
end

% Where have our instruments been deployed
fprintf('Querying...\n');
deployments = dbDeploymentInfo(query_h, varargin{:});
fprintf('Found %d deployments, generating %s\n', length(deployments), kmlfile);

% Create project folders?
projects = unique({deployments.Project});

% Let's use the kmltoolbox to plot things
earth = kml(kmlfile);  

% Create project folders?
projects = unique({deployments.Project});
if length(projects) > 1
    for fidx=1:length(projects)
        fprojects(fidx) = earth.createFolder(projects{fidx});
    end
    folderIdx = zeros(length(deployments), 1);
    for didx= 1:length(deployments)
        folderIdx(didx) =  find(strcmp(deployments(didx).Project, projects));
    end
else
    fprojects(1) = earth;
    folderIdx = ones(length(deployments),1);
end

if First
    % Find the first deployment for each site
    sites = unique({deployments.Site});
    sitesN = length(sites);
    siteIdx = zeros(1, sitesN);
    range = zeros(1, sitesN)
    for sidx = 1:sitesN
        % Find deployments matching this site and pick the first one
        siteP = arrayfun(@(x) strcmp(x, sites{sidx}), {deployments.Site});
        positions = find(siteP);
        [~, firstDepPos] = min(vertcat(deployments(siteP).DeploymentID));
        range(sidx) = positions(firstDepPos);
    end
else
    range = 1:length(deployments);        
end

for idx=range
    if isnumeric(deployments(idx).Site)
        % xml converter does not look at Schema and converts digits
        % to numbers
        site = num2str(deployments(idx).Site);
    else
        site = deployments(idx).Site;
    end
            
    % Work around for database inconsistencies where some fields are
    % not populated correctly.
    if isfield(deployments(idx).DeploymentDetails, 'TimeStamp') && ...
            isfield(deployments(idx).RecoveryDetails, 'TimeStamp') && ...
        ~ isempty(deployments(idx).DeploymentDetails.TimeStamp) && ...
        ~ isempty(deployments(idx).RecoveryDetails.TimeStamp) && ...
        isnumeric(deployments(idx).DeploymentDetails.Longitude) && ...
        isnumeric(deployments(idx).DeploymentDetails.Latitude)
        
        if ~isfield(deployments(idx).DeploymentDetails, 'DepthInstrument_m')
            deployments(idx).DeploymentDetails.DepthInstrument_m = 0;
            fprintf('%s Missing depth, using 0 m\n', siteid);
        end
        
        if First
            siteid = sprintf('%s %s', ...
                deployments(idx).Project, site);
        else
            siteid = sprintf('%s %s:%d', ...
                deployments(idx).Project, site, deployments(idx).DeploymentID);
        end         

        if Timestamp
            timeargs = ...
                {'timespanBegin', deployments(idx).DeploymentDetails.TimeStamp, ...
                'timespanEnd', deployments(idx).RecoveryDetails.TimeStamp};
        else
            timeargs = {};
        end
        fprojects(folderIdx(idx)).point(...
            deployments(idx).DeploymentDetails.Longitude, ...
            deployments(idx).DeploymentDetails.Latitude, ...
            -deployments(idx).DeploymentDetails.DepthInstrument_m, ...
            'name', siteid, timeargs{:});
    else
        fprintf(...
            '%s %s:%d Skipping due to missing deployment timestamp\n', ...
            deployments(idx).Project, site, deployments(idx).DeploymentID);
    end
end

earth.save(kmlfile)
if Display
    earth.run()
end