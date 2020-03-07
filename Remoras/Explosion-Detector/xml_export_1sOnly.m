function xml_export_1sOnly(sppID)

%Inputs:
%SpeciesID - either 'minke' or 'anthro'
%----When using Minke, call is set to Boing
%----When using Anthro, call is set to Explosion
%
%

out_dir = 'c:\test'; %where would you like the XML file to go?
mat_dir = 'C:\Users\seano\Documents\amanda\mats'; %where are the mat files stored?
files = dir(fullfile(mat_dir,'*.mat')); % Set folder path

%don't think need this anymore since parm is saved into each matfile:
%load('C:\Users\seano\Documents\amanda\exp_parm.mat')


%% imports, tethys query stuff
import tethys.nilus.*;
query_h = dbInit('Server','bandolero.ucsd.edu');


%% Process User Input


%Determine call from sppID
sppID = lower(sppID);
switch(sppID)
    case 'minke'
        speciesID = 180524;
        call='Boing';
        %using minke detector, save
        algorithm = 'GPL_code';
        %Prompt asking which type of minke code was ran
        canonical = input('Did you run canonical? [1 for yes, 0 for no]:  ');
        if canonical
            version = 'canonical';
        else
            version = '20140430'; %the numeric version, should change when updated
        end
    case 'anthro'
        speciesID = 180092;
        algorithm = 'SBP_Explosion';
        version = '1';
        method = 'Spectrogram Correlation';
        call = 'Explosion';
    otherwise
        error('Invalid speciesID');
end








%% Effort Time Info
% sampling start/end grabbed from Tethys, and sets them as effort start/end
manual = 0;
% to enter manually, uncomment the THREE lines, and follow the format provided
% manual = 1;
% effstart = '2000-12-01T23:59:00Z';
% effend = '2001-12-01T23:59:00Z';


%% XML Preamble
det = Detections(); %create Detections object
det.setUserID('acummins');

%set effort details
granularity='call'; %always true, yes?
det.addKind(speciesID,{granularity,call});

%set algorithm information
if speciesID == 180092
    det.setAlgorithm({algorithm,version,method});
else
    det.setAlgorithm({algorithm,version});
end




%% Unaltered code, Additions @ 91-130
% Exports explosions verification data from "bt" into Excel
% Must run this program from within the explosions folder
% Updated to export only 1s in bt and skip over empty bt files



jj = 1;
nn = 1;
place = 0;


% Load bt data from each mat file and store into bt_combined array
for k = 1:length(files)
    load(fullfile(mat_dir,files(k).name));
    if k == 1
        %Grab Info from first matfile
        %First, pro/de/si (project, site,deployment)
        %some funky parsing taking place, but it works.
        splitname = strsplit(files(1).name,'_');
        prodesi = splitname{4};
        if strcmp(prodesi,'GofAK')
            project = prodesi;
            desi = splitname{5};
            deployment = desi(isstrprop(desi,'digit'));
            deployment = str2double(deployment);
            site = desi(isstrprop(desi,'alpha'));
        else
            deployment = prodesi(isstrprop(prodesi,'digit')); %grab numeric characters
            depl_idx = strfind(prodesi,deployment); %note location of deployment
            project = prodesi(1:depl_idx-1); %everything before deployment should be proj
            desi = prodesi(depl_idx:end); %pull out deployment and site only, seems necessary
            site = desi(isstrprop(desi,'alpha')); %pull out alpha characters from de/si
            deployment = str2double(deployment); %convert to double
        end
        det.setSite(project,site,deployment);
        
        %grab&set start/end time from Tethys
        if ~manual
            depl_info = dbDeploymentInfo(query_h,'Project',project','Site',...
                site,'DeploymentID',deployment);
            effstart = depl_info.SamplingDetails.Channel.Start;
            effend = depl_info.SamplingDetails.Channel.End;
        end
        det.setEffort(effstart,effend);
        
        %next, lets grab algorithm parameters
        %Define algorithm parameters, different for Minkes vs Humans
        
        param_names = fieldnames(parm);
        for pidx=1:length(param_names)
            p_name = param_names{pidx};
            p_val = extractfield(parm,p_name);
            tags(pidx) = Tag(p_name,p_val);
        end
        det.addAlgorithmParameters(tags);
        
    end
    bt_combined=[];
    [len,wid] = size(bt);
    if len ~= 0
        if place == 0
            for j = 1:len
                if bt(j,3) == 1
                    bt_combined(jj,:) = bt(j,:);
                    jj = jj+1;
                end
            end
        else
            place = length(bt_combined(:,1))+1; % location of row for start of next bt
            for n = 1:len
                if bt(n,3) == 1
                    bt_combine(nn,:) = bt(n,:);
                    nn = nn+1;
                end
                if bt(n,:) ~= 0
                    kk = place+length(bt_combine(:,1));
                    for m = place:kk-1
                        bt_combined(m,:) = bt_combine(m-place+1,:);
                    end
                end
            end
        end
    end
    disp(['Added bt #' num2str(k) ' out of ' num2str(length(files)) ' to bt_combined']);
    clear bt;
    clear bt_combine;
    nn = 1;
end



%% add processed detection data to xml

if ~isempty(bt_combined)
    dets.Times(:,1) = dbSerialDateToISO8601(bt_combined(:,4));
    dets.Times(:,2) = dbSerialDateToISO8601(bt_combined(:,5));
    
    
    for didx=1:length(dets.Times)
        oed=Detection(dets.Times(didx,1),speciesID); %set start time and species code
        oed.setEnd(dets.Times(didx,2));
        oed.addCall(call);
        det.addDetection(oed);
    end
end



%% Output to file...
fname = fullfile(out_dir,strcat(prodesi,'_automatic_',call,'.xml'));
det.marshal(fname);






%%%%%%%%%%%%%%%DEPRECATED:




% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Convert matlab times to excel times
% excelStart = bt_combined(:,4)-ones(size(bt_combined(:,4))).*datenum('30-Dec-1899');
% excelEnd = bt_combined(:,5)-ones(size(bt_combined(:,5))).*datenum('30-Dec-1899');
% 
% % Exports the bt_combined array data into excel file
% lengt = length(bt_combined)+1;
% cellmat = cell(lengt,5);
% cellmat{1,1} = 'Sample Points 1';
% cellmat{1,2} = 'Sample Points 2';
% cellmat{1,3} = 'Detection';
% cellmat{1,4} = 'Start Time';
% cellmat{1,5} = 'End Time';
% 
% for idx = 1:length(bt_combined)
%     cellmat{idx+1,1} = bt_combined(idx,1);
%     cellmat{idx+1,2} = bt_combined(idx,2);
%     cellmat{idx+1,3} = bt_combined(idx,3);
%     cellmat{idx+1,4} = excelStart(idx,1);
%     cellmat{idx+1,5} = excelEnd(idx,1);
% end
% 
% xlswrite('SOCAL47H_explosions.xls', cellmat); % Rename this each time
% disp('Finished writing data to excel file');
% 
% 
