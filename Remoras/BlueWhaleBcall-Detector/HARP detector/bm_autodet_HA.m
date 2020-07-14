function bm_autodet_HA(det, init_params, from_dir, filename, outfile)

% scroll through xwav file - adapted from Shyam's BatchClassifyBlueCalls
% smk 100219

% ideal for window lengths greater than 1 raw file (75s).  As is, raw file
% length in seconds must be hard-coded.  
% Modified to work with xwavs of any raw file lenth (as 180517)

% now actually works with xwavs of variable lengths, namely for BW data
% fr 180816 

global PARAMS REMORA

%import XML package
import tethys.nilus.*;
 
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

% set up XML variables, preamble
% BmB det parameter values
if ~from_dir  
    det = Detections();
    q = dbInit('Server', 'bandolero.ucsd.edu', 'Port', 9779); % set up query handler
    userid = 'arice'; % change to your username, usually firstinitial+lastname(jdoe)
    soft = 'autodet'; % "name of the software that implements the algorithm"
    version = '1.0';  % change to reflect version the software
    method = 'Energy Detector'; % this line is optional, just a description of the algorithm
    granularity = 'call'; % type of granularity, allowed: call, encounter, binned
    call = 'B NE '; % string to describe calls of interest
    speciesID = 180528; % TSN for Blue Whales
    
    % grab information from file header (PARAMS)
    project = PARAMS.xhd.ExperimentName(...
        isstrprop(PARAMS.xhd.ExperimentName,'alpha'));
    deployment = str2double(PARAMS.xhd.ExperimentName(isstrprop(...
        PARAMS.xhd.ExperimentName,'digit')));
    site = PARAMS.xhd.SiteName(isstrprop(...
        PARAMS.xhd.SiteName,'alphanum'));
    
    % effort time; compare to wake up time in the HARP DB
    query = sprintf('collection("Deployments")/ty:Deployment[Project="%s"][DeploymentID="%02d"][Site="%s"]/SamplingDetails/Channel/Start', project, deployment,site);
    start_elem = char(q.QueryTethys(query));
    wake_up = dbISO8601toSerialDate(strtok(...
        start_elem(8:length(start_elem)),'<'));
    for tidx=1:length(PARAMS.raw.dnumStart)
        if PARAMS.raw.dnumStart(tidx)+dateoffset >= wake_up
            effStart = dbSerialDateToISO8601(PARAMS.raw.dnumStart(tidx)+dateoffset);
            break; % jump out the loop, we've found the time
        end
    end
    effEnd = dbSerialDateToISO8601(PARAMS.end.dnum+dateoffset);
    
    % add what we have so far to the Detections object
    det.setUserID(userid);
    det.setSite(project,site,deployment);
    det.setEffort(effStart, effStart);%start and end set equal, change later.
    det.addKind(speciesID,{granularity,call});
    det.setAlgorithm({soft,version, method});

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
    XMLfindcalls(det, init_params);

    % exit if we've reached the end
    if PARAMS.raw.endIndex == num_rfs
        break;
    end
    
    % turn off parameters initialization 
    init_params = 0;
end

%close out with effort
if ~from_dir
    det.setEffort(effStart,effEnd);
    det.marshal(xml_out);
end

fclose(PARAMS.outfid);