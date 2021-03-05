function bm_autodet_dir_LB

% Adapted from decimatexwav_dir
% smk 100219
% Updated to look for only xwavs and output to .xls (not .txt)
% smk 110603

% removed dependencies from older codebase and allowed for use with non
% continous xwav data 
% fr 180816 

% Adapted from XMLautodet_dir
% Modified to resolve issues reading xwav files with Tethys 2.5 update
% lb 030221

% set up workspace
query_h = dbInit('Server','breach.ucsd.edu','Port',9779); % setup query handler
import nilus.*; % make nilus classes accessible
global PARAMS REMORA HANDLES detections marshaller helper effort

% make sure correct .jar file is on javaclasspath
paths = javaclasspath('-static');
found = false;
for i = length(paths)-10:length(paths)
   if ~isempty(strfind(char(paths{i}), 'nilus'))
       found = true;
      break;
   end
end

% if the connector was not immediately found
if ~found
   errordlg('nilus.jar not found. Add to javaclasspath and rerun.');
end

% get all the input parameters for the run
% get_params;
% if ~REMORA.dt_bwb.success; disp('Detector run cancelled.'); return; end;

% load detector parameters 
% [odir, ~, ~] = fileparts(which('bm_autodet_dir_HA'));
% copyfile(REMORA.dt_bwb.params_file, fullfile(odir, 'temp_bwb_params.m'));
% temp_bwb_params;
% delete(fullfile(odir, 'temp_bwb_params.m'));

% input parameters
ii = 1;
defdir = '';   % default directory
idir{ii} = REMORA.bm.settings.inDir;
PARAMS.outpath = REMORA.bm.settings.outDir;

% Display number of files in directory
d = dir(idir{ii});    % directory info
fn = {d.name}';       % file names in directory
str = '.x.wav';
k = strfind(fn, str);
for m = 1:length(k)
    n(m,1) = isempty(k{m,1});
end
x = n == 0;
xwavs = fn(x);
xnum = size(xwavs);
numx = xnum(1);

% create names for output files
PARAMS.inpath = idir{1,1};
PARAMS.infile = xwavs(1,:);
PARAMS.infile = PARAMS.infile{1,1};
rdxwavhd;
dataID = sprintf('%s%s', strrep(PARAMS.xhd.ExperimentName, '_', ''), strrep(PARAMS.xhd.SiteName, '_', ''));
PARAMS.outfile = sprintf('%s_kern%s_thresh%d.xls',dataID,REMORA.bm.settings.kernelID,REMORA.bm.settings.thresh);
PARAMS.outfile = strrep(PARAMS.outfile, '__', '_');

% make sure we don't mess with triton functionality but are able to use
% triton functions
if isfield(HANDLES, 'fig')
    REMORA.dt_bwb.tempfig = HANDLES.fig;
    HANDLES = rmfield(HANDLES, 'fig');
else 
    REMORA.dt_bwb.tempfig = [];
end

xml_out = sprintf(sprintf('%s_kern%s_thresh%d.xml',dataID,REMORA.bm.settings.kernelID,REMORA.bm.settings.thresh)); 
xml_out = fullfile(PARAMS.outpath, xml_out);

% set up XML variables, preamble
% set up parent objects
detections = Detections(); % create detections object
marshaller = MarshalXML(); % allows user to convert (marshal) the detections object to XML
helper = Helper(); % helper class helps user build objects

% initialize required elements from above using helper object
% (DataSource, Algorithm, UserID, Effort, OnEffort)
helper.createRequiredElements(detections);

% Effort
effort = DetectionEffort(); % used to easily set start and end times

from_dir = 1; % tell autodet it's working through a directory

for jj = 1:numx
    directory.inpath = idir;
    directory.infiledet = xwavs(jj,:); % get file names sequentally
    
    PARAMS.inpath = directory.inpath{1,1};
    PARAMS.infile = directory.infiledet{1,1};
    
    filename = fullfile(directory.inpath,directory.infiledet);
    disp(['Looking for calls in  ' filename{1,1}])
    if jj == 1 % first run
        
        % grab header info from it
        rdxwavhd; 
        
        project = PARAMS.xhd.ExperimentName(...
            isstrprop(PARAMS.xhd.ExperimentName,'alpha'));
        deployment = str2double(PARAMS.xhd.ExperimentName(...
            isstrprop(PARAMS.xhd.ExperimentName,'digit')));
        site = PARAMS.xhd.SiteName(...
            isstrprop(PARAMS.xhd.SiteName,'alphanum'));
        first_xwav = 1; % set parameters the first time
        
        % effort time; compare to wake up time in the HARP DB
        query = sprintf('collection("Deployments")/ty:Deployment[Project="%s"][DeploymentID="%02d"][Site="%s"]/SamplingDetails/Channel/Start', project, deployment,site);
        start_elem = char(query_h.QueryTethys(query));
        
        % is this deployment even in the database?
        if isempty(start_elem)
            disp('Deployment not found in Tethys, try manual entry.');
            
            % give user an option to manually enter deployment info 
            prompt = {'Project: ', 'Site: ', 'Deployment #: '};
            title = 'Deployment Info';
            info = inputdlg(prompt, title);
            number = str2num(info{3});
            
            % construct a new query
            query = sprintf('collection("Deployments")/ty:Deployment[Project="%s"][DeploymentID="%02d"][Site="%s"]/SamplingDetails/Channel/Start',info{1},number,info{2});
            start_elem = char(query_h.QueryTethys(query));
            
            if isempty(start_elem)
                disp('Deployment not in Tethys. Continuing without XML creation.');
            end
        end
        
        if ~isempty(start_elem)
            wake_up = dbISO8601toSerialDate(...
                strtok(start_elem(8:length(start_elem)),'<'));

            for tidx=1:length(PARAMS.raw.dnumStart)
                if PARAMS.raw.dnumStart(tidx)+dateoffset >= wake_up
                    startSerial = PARAMS.raw.dnumStart(tidx) + dateoffset;
                    effStart = dbSerialDateToISO8601(startSerial);
                    effort.setStart(helper.timestamp(effStart));
                    break; % jump out of the loop, we've found the time
                end
            end
        end
    else
        first_xwav = 0;
    end
    
    % create storage variables to hold info user wants
    userid = 'lbalitaan'; % usually first initial, full last name
    detections.setUserID(userid);
    
%     % set up a query handler 
%     query_h = dbInit('Server','breach.ucsd.edu','Port',9779);
%     
%     % use the handler to query for a Latin name
%     species = query_h.QueryTethys('lib:completename2tsn("Balaenoptera musculus")');
%     % or a species abbreviation map:
%     %species = query_h.QueryTethys('lib:abbrev2tsn("Bm","NOAA.NMFS.v1")');
    
    % get the DataSource from the detections object
    dataSource = detections.getDataSource();
    dataSource.setProject(project);
    dataSource.setDeployment(helper.toXsInteger(deployment)); 
    dataSource.setSite(site);
    
    % get algorithm block (lets user know what methods were used to find detections)
    algorithm = detections.getAlgorithm();
    algorithm.setSoftware('autodet'); % "name of the software that implements the algorithm"
    algorithm.setVersion('1.0'); % change to reflect version the software
    algorithm.setMethod('Spectrogram Correlation'); % this line is optional, just a description of the algorithm 
    
    % returns a list object that individual kinds will be added to
    kinds = effort.getKind();

    % build individual kind
    kind = DetectionEffortKind();
    
    % call
    calltype = CallType();
    calltype.setValue('B NE Pacific');
    kind.setCall(calltype);
    
    % granularity
    granularitytype = GranularityEnumType.fromValue('call');
    granularity = GranularityType();
    granularity.setValue(granularitytype);
    kind.setGranularity(granularity);
    
    %speciesID
    species = 180528; % TSN for blue whales
    species_int = helper.toXsInteger(species);
    speciestype = SpeciesIDType();
    speciestype.setValue(species_int);
    kind.setSpeciesID(speciestype);
    
    kinds.add(kind); % add back to kinds list
    
    % Now set the effort against the detections object
    detections.setEffort(effort);

%     try
        bm_autodet_LB(detections, first_xwav, from_dir, [filename{1,1}], fullfile(PARAMS.outpath, PARAMS.outfile))
%     catch e
%         if jj==1
%             disp('autodet failed on first file')
%             disp(['setting EffortEnd to: ',datestr(startSerial),'+', e.cause{1,1}.message, ' seconds...']);
%             days = str2double(e.cause{1,1}.message) * dps;
%             disp(['end set to: ',datestr(startSerial+days)]);
%             effEnd = dbSerialDateToISO8601(startSerial+days);
%             break;
%         else
%             directory.infiledet = xwavs(jj-1,:);
%             filename = strcat(directory.inpath,directory.infiledet);
%             known_hdr = ioReadXWAVHeader(filename{1,1});%append: ...,'ftype',1) for wav
%             endSerial = known_hdr.end.dnum+dateoffset;
%             disp(['setting EffortEnd to the previous file''s end time: ',datestr(endSerial),'+', e.cause{1,1}.message, ' seconds...']);
%             days = str2double(e.cause{1,1}.message) * dps;
%             disp(['end set to: ', datestr(endSerial+days)]);
%             effEnd = dbSerialDateToISO8601(endSerial+days);
%             break;
%         end
%     end
    if jj==numx
        % grab endtime
        rdxwavhd;
         effEnd = dbSerialDateToISO8601(PARAMS.end.dnum+dateoffset);
         effort.setEnd(helper.timestamp(effEnd));
    end
    % Now set the effort against the detections object
     detections.setEffort(effort);
end

% if ~isempty(start_elem)
%     % Set up preamble (metadata)
%     % create storage variables to hold info user wants
%     userid = 'lbalitaan'; % usually first initial, full last name
%     detections.setUserID(userid);
%     species = 180528; % TSN for blue whales
%     
% %     % set up a query handler 
% %     query_h = dbInit('Server','breach.ucsd.edu','Port',9779);
% %     
% %     % use the handler to query for a Latin name
% %     species = query_h.QueryTethys('lib:completename2tsn("Balaenoptera musculus")');
% %     % or a species abbreviation map:
% %     species = query_h.QueryTethys('lib:abbrev2tsn("Bm","NOAA.NMFS.v1")');
%     
%     % get the DataSource from the detections object
%     dataSource = detections.getDataSource();
%     dataSource.setProject(project);
%     dataSource.setDeployment(helper.toXsInteger(deployment));
%     dataSource.setSite(site);
%     
%     % get algorithm block (lets user know what methods were used to find detections)
%     algorithm = detections.getAlgorithm();
%     algorithm.setSoftware('autodet'); % "name of the software that implements the algorithm"
%     algorithm.setVersion('1.0'); % change to reflect version the software
%     algorithm.setMethod('Spectrogram Correlation'); % this line is optional, just a description of the algorithm
%     
%     % Effort
%     effort = DetectionEffort(); % used to easily set start and end times
%     effort.setStart(helper.timestamp(effStart));
%     effort.setEnd(helper.timestamp(effEnd));
%     
%     % returns a list object that individual kinds will be added to
%     kinds = effort.getKind();
% 
%     % build individual kind
%     kind = DetectionEffortKind();
%     
%     % call
%     calltype = CallType();
%     calltype.setValue('B NE Pacific');
%     kind.setCall(calltype);
%     
%     % granularity
%     granularitytype = GranularityEnumType.fromValue('call');
%     granularity = GranularityType();
%     granularity.setValue(granularitytype);
%     kind.setGranularity(granularity);
%     
%     %speciesID
%     species_int = helper.toXsInteger(species);  % ITIS taxonomic serial  number
%     speciestype = SpeciesIDType();
%     speciestype.setValue(species_int);
%     kind.setSpeciesID(speciestype);
%     
%     kinds.add(kind); % add back to kinds list
%     
%     % Now set the effort against the detections object
%     detections.setEffort(effort);
%  end
 
% reset HANDLES variable for normal triton function
HANDLES.fig = REMORA.dt_bwb.tempfig;
 
disp('Blue whale B call detection complete.')
 
end