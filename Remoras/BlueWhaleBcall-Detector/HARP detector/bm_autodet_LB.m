function bm_autodet_LB(~, init_params, from_dir, filename, outfile)

% scroll through xwav file - adapted from Shyam's BatchClassifyBlueCalls
% smk 100219

% ideal for window lengths greater than 1 raw file (75s).  As is, raw file
% length in seconds must be hard-coded.  
% Modified to work with xwavs of any raw file lenth (as 180517)

% now actually works with xwavs of variable lengths, namely for BW data
% fr 180816 

% Adapted from bm_autodet_HA
% Modified to resolve issues reading xwav files with Tethys 2.5 update
% lb 030221

import nilus.*; % make nilus classes accessible
global PARAMS REMORA effort helper detections marshaller
 
REMORA.dt_bwb.win_len = 2250; % approximate window length in seconds
PARAMS.ch = 1;

% are we dealing with wavs or xwavs?
PARAMS.ftype = 2; % confirm xwav
if isempty(strfind(filename, '.x.wav'))
    PARAMS.ftype = 1;
end

% write xwav file name into excel sheet
PARAMS.outfid = fopen(outfile, 'a');   % Open xls file to write to
% fprintf(out_fid, '%s\n', filename); % print xwav file name

% grab metadata from this xwav
[PARAMS.inpath, PARAMS.infile, ext] = fileparts(filename);
PARAMS.infile = [PARAMS.infile, ext];
rdxwavhd;

% BmB detections parameter values
if ~from_dir
%     detections = Detections(); % create detections object
%     marshaller = MarshalXML(); % allows user to convert (marshal) the detections object to XML
%     helper = Helper(); % helper class helps user build objects
%     
%     % initialize required elements from above using helper object
%     helper.createRequiredElements(detections);

    query_h = dbInit('Server', 'breach.ucsd.edu', 'Port', 9779); % set up query handler
    
    % create storage variables to hold info user wants
    userid = 'lbalitaan'; % change to your username, usually firstinitial+lastname(jdoe)
    detections.setUserID(userid);
    
    % set up DataSource element
    dataSource = detections.getDataSource(); % get DataSource from detections object
    
    % grab information from file header (PARAMS)
    project = PARAMS.xhd.ExperimentName(...
        isstrprop(PARAMS.xhd.ExperimentName,'alpha'));
    deployment = str2double(PARAMS.xhd.ExperimentName(isstrprop(...
        PARAMS.xhd.ExperimentName,'digit')));
    site = PARAMS.xhd.SiteName(isstrprop(...
        PARAMS.xhd.SiteName,'alphanum'));
    
    % Set project, deployment, site
    dataSource.setProject(project);
    dataSource.setDeployment(helper.toXsInteger(deployment));
    dataSource.setSite(site);
    
    % get algorithm block
    algorithm = detections.getAlgorithm();
    
    % set its components:
    algorithm.setSoftware('autodet'); % "name of the software that implements the algorithm"
    algorithm.setVersion('1.0'); % change to reflect version the software
    
    method = 'Spectrogram Correlation'; % this line is optional, just a description of the algorithm
    granularity = 'call'; % type of granularity, allowed: call, encounter, binned
    call = 'B NE Pacific'; % string to describe calls of interest

    % effort time; compare to wake up time in the HARP DB
    effort = DetectionEffort();
    query = sprintf('collection("Deployments")/ty:Deployment[Project="%s"][DeploymentID="%02d"][Site="%s"]/SamplingDetails/Channel/Start', project, deployment,site);
    start_elem = char(query_h.QueryTethys(query));
    wake_up = dbISO8601toSerialDate(strtok(...
        start_elem(8:length(start_elem)),'<'));
    for tidx=1:length(PARAMS.raw.dnumStart)
        if PARAMS.raw.dnumStart(tidx)+dateoffset >= wake_up
            effStart = dbSerialDateToISO8601(PARAMS.raw.dnumStart(tidx)+dateoffset);
            effort.setStart(helper.timestamp(effStart));
            break; % jump out the loop, we've found the time
        end
    end
    effEnd = dbSerialDateToISO8601(PARAMS.end.dnum+dateoffset);
    effort.setEnd(helper.timestamp(effEnd));
    detections.setEffort(effort); % Now set the effort against the detections object
    
    % Kinds
    kinds = effort.getKind(); % this returns a list object that individual kinds will be added to
    kind = DetectionEffortKind(); % To build individual kinds
    
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
     speciesID = 180528; % TSN for blue whales
     species_int = helper.toXsInteger(speciesID);
     speciestype = SpeciesIDType();
     speciestype.setValue(species_int);
     kind.setSpeciesID(speciestype);
     
     % add back to Kinds list
     kinds.add(kind);
     
     % Now set the effort against the detections object
     detections.setEffort(effort);   
end

% abbreviations for xhd stuff
num_rfs = PARAMS.xhd.NumOfRawFiles;

% for differently sized rfs - figure out how many rfs fit into 2250
% seconds 
rf_durs = PARAMS.xhd.byte_length/PARAMS.xhd.ByteRate;
dur = mean(rf_durs); 
rfs_win = floor(2250/dur); % number of rfs/window

% make sure interval is an even number
if mod(rfs_win, 2) == 1
    rfs_win = rfs_win + 1;
end

% do we need to initialize parameters?
if ~from_dir 
    init_params = 1;
end

% for now, window is 30 rfs, incremented by 15 each time
for k = 1:rfs_win/2:num_rfs
    
    PARAMS.raw.currentIndex = k;
    
    % incomplete last window
    if k + rfs_win-1 > num_rfs
        PARAMS.raw.endIndex = num_rfs;
    else
        PARAMS.raw.endIndex = k+rfs_win-1;
    end
    
    % run detector on the window
     bm_findcalls_LB(detections, init_params);

    % exit if we've reached the end
    if PARAMS.raw.endIndex == num_rfs
        break;
    end
    
    % turn off parameters initialization 
    init_params = 0;
end

%close out with effort
if from_dir
    effEnd = dbSerialDateToISO8601(PARAMS.end.dnum+dateoffset);
    effort.setEnd(helper.timestamp(effEnd));
    detections.setEffort(effort);
    dataID = sprintf('%s%s', strrep(PARAMS.xhd.ExperimentName, '_', ''), strrep(PARAMS.xhd.SiteName, '_', ''));
    xml_out = sprintf(sprintf('%s_kern%s_thresh%d.xml',dataID,REMORA.bm.settings.kernelID,REMORA.bm.settings.thresh)); 
    xml_out = fullfile(PARAMS.outpath, xml_out);
    marshaller.marshal(detections, xml_out);
end

fclose(PARAMS.outfid);