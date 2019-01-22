function plots = visWeeklyEffort(queryEng, varargin)

%plots = visWeeklyEffort(queryEngine, Arguments);
% Generate a plot of detections and effort by week for a given species.
% Detections can be narrowed down by Call, call subtype, and or species
% Group. Multiple deployments for a given site can be appended to the same
% plot, but multiple sites will have their own plot.
%
% Right hand Y Axis will always correspond to percentage of effort for that
% week, denoted by a dot if less than 100%. The left hand axis will be either:
% Cumulative hours per week - for encounter granularity
% Total Detections per week - for call granularity.
%
% queryEng must be a Tethys database query object, see dbDemo() for an
% example of how to create one.
%
% The plots return variable contains all of the information passed to the
% script that actually generates the plots, such as start end times,
% species IDs, etc.
%
% Use the following keywords as a string, followed by the desired value.
%
% Required Input Arguments:
% 'Project', string - Name of project data is associated with, e.g. SOCAL
% 'Site', string - name of location where data was collected. For multiple
%          sites use a cell array, e.g. {'A','B','C'}
% 'Deployment', integer | array - Which deployment of sensor at a given
%         location. For multiple deployments, use an array, e.g. [1 2 3] or [1:3]
% 'SpeciesID', string - species/family/order/... name.  Format depends on the last
%        call to dbSpeciesFmt. For multiple species, use a cell array of
%        strings.
% 'Call' - type of call. To plot all calls use 'all'. For multiple calls,
%       use a cell array. E.g. {'Clicks','Whistles'}
% 'Granularity', string - Type of effort. If using binned, must specify
%      'BinSize_m' as well, see below. Currently, only hourly bins are properly
%       plotted
%
% Multiple species and calls can be input at one time, each creating their
% own plot. Individual cell arrays must be input to house the calls for
% each species. Also, each species entry must correspond to a
% matching position in the cell array of calls. e.g.
%
%...,'SpeciesID',{'Oo','Bb'},'Call',{{'Clicks','Whistles'},{'downsweep'}},
%
% here, plots will be made for Oo clicks, Oo whistles, and Bb downsweeps.
%
% Optional Inputs:

% For manually input date times for plotting use these. Otherwise the code
% will search for the deployment start/end based on project, site and
% deployment inputs. e.g. datenum([YYYY MM DD HH MM SS])
% 'Start',datenum - start of plotting
% 'End', datenum - end of plotting
%
% Other inputs:
% 'BinSize_m', integer - if using a granularity of binned, specify the size
% of the bin. Note: Hourly bins (60) are the ONLY reliable plot currently.
% 'Subtype', string - subtype of call. Must be used as within a cell array, e.g.
%       ...,'Call',{'Clicks','Subtype','<20kHz')
% 'Group', string - Species Group, will apply to ALL species input.
% 'Yearly', true | false (default) - if plotting deployments that span many
% years, setting to true will append yearly subplots on to a single figure.
% 'SaveTo', string - allows saving of a jpeg to the output path specified.
% 'Duty', true (default) | false - if changed to false, will skip pulling
% deployment info for the given site/project/deployment
%
% Full Example:
%
% visWeeklyEffort(qb,'Project','SOCAL','Site',{'M','N','H','G2','E'},...
% 'Deployment',[31:51],'SpeciesID',{'Lo','Oo'},'Granularity','encounter',...
% 'Call',{{'Clicks'},{'Clicks','Whistles'}},'ByYear',true,...
% 'SaveTo','C:\users\seano\desktop\plots');
%





%Path to save plots
path = '';
%defaults, overwritten via user input
save=0;
sub_yr=0;
start = false;
stop = false;
usr_max=false;      



%%%%%%%%%%%%%%%%%%%%%%%%%%SET UP VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%

vidx=1;
site_cells={};
deployment_array={};
spp_cells = {};
duty = true;

%input counts
site_count = 0;
depl_count = 0;
spp_count = 0;
document = false; %flag -- do we process using DocID?
grouped = false;
subbed = false; %flag - does this query include a subtype?
all = false; %flag - are we asking for all call types?
req_input = 0; %totals up required arguments, verifys total afterwards

while vidx <= length(varargin)
    switch varargin{vidx}
        case 'Document'%not implemented
            doc_id = strcat('dbxml:///Detections/', varargin{vidx+1});
            document = true;
            vidx = vidx+2;
        case 'Project'
            project = varargin{vidx+1};
            req_input = req_input+1;
            vidx = vidx+2;
        case 'Granularity'
            granularity = varargin{vidx+1};
            binned = strcmp(granularity,'binned');
            calls = strcmp(granularity,'call');
            req_input = req_input+1;
            vidx = vidx+2;
        case 'Site'
            if iscell(varargin{vidx+1})
                site_cells = varargin{vidx+1};
                site_count = length(site_cells);
            else
                site_cells = varargin(vidx+1);
                site_count = 1;
            end
            req_input = req_input+1;
            vidx = vidx+2;
        case 'Deployment'
            if iscell(varargin{vidx+1})
                depl_cells = varargin{vidx+1};
                for i=1:length(depl_cells)
                    depl_count = depl_count+numel(depl_cells{i});
                end
            else
                deployment_array = sort(varargin{vidx+1});
                depl_count = length(deployment_array);
            end
            req_input = req_input+1;
            vidx = vidx+2;
        case 'SpeciesID'
            if iscell(varargin{vidx+1})
                spp_cells = varargin{vidx+1};
                spp_count = length(spp_cells);
            else
                spp_cells = varargin(vidx+1);
                spp_count = 1;
            end
            req_input = req_input+1;
            vidx = vidx+2;
        case 'Group'
            group = varargin{vidx+1};
            grouped = true; % flag
            vidx = vidx+2;
        case 'Call'
            if iscell(varargin{vidx+1})
                call_cells = varargin{vidx+1};
            else
                call_cells = {varargin(vidx+1)};
            end
            req_input = req_input+1;
            vidx = vidx+2;
        case 'SaveTo'
            path = varargin{vidx+1};
            save = true;
            vidx =vidx+2;
        case 'Yearly'
            sub_yr = varargin{vidx+1};
            vidx = vidx+2;
        case 'Start'
            usr_start = varargin{vidx+1};
            start=true;
            vidx=vidx+2;
        case 'End'
            usr_stop = varargin{vidx+1};
            stop = true;
            vidx=vidx+2;
        case 'YMax'             
            usr_max = true;      
            yMax = varargin{vidx+1};     
            vidx = vidx+2;       
        case 'BinSize_m'
            binsize_m = varargin{vidx+1};
            vidx = vidx+2;
        otherwise
            error('Bad arugment:  %s', varargin{vidx});
    end
end

%If there is only once species, and multiple calls, put call cells into
%another cell for processing. Why must this be done? Because I am an
%amateur programmer.


    
%Make sure all four required inputs have been input
if ~document
    if ~(req_input==6)
        error('Missing an Argument: Project, Deployment, Site, SpeciesID, Call or Granularity');
    end
end

% %% Document ID Section
% % plot info is pulled from document itself rather than user input.
% if document
%     %fixed variables
%     site_count = 1;
%     depl_count=1;
%     
%     dbSpeciesFmt('Output','tsn');
%     dbSpeciesFmt('Input','tsn');
%     fprintf('Retrieving metadata from Document: %s\n',doc_id(21:end));
%     [doc_eff,char] = dbGetEffort(queryEng,'Document',doc_id);
%     if ~isempty(doc_eff)
%         iseff=true;
%     else
%         error('Document ''%s'' could not be found', doc_id(21:end));
%     end
%     %Grab datasource info
%     project = char.DataSource.Project;
%     site_array = {char.DataSource.Site};
%     deployment_array = char.DataSource.Deployment;
%     
%     %Granularity is assummed to be uniform across submission
%     granularity = char(1).Kind(1).Granularity;
%     binned = strcmp(granularity,'binned');%flags for processing method
%     calls = strcmp(granularity,'call');
%     
%     %loop thru n grab species
%     spidx=1; %counter for species
%     for cidx = 1:length(char)
%         for kidx = 1:length(char(cidx).Kind)
%             spp_array{spidx,1} = num2str(char(cidx).Kind(kidx).SpeciesID);
% 
%             if ~isempty(char(cidx).Kind(kidx).SpeciesID_attr)
%                 spp_array{spidx,2} = char(cidx).Kind(kidx).SpeciesID_attr.Group;
%             end
%             spidx = spidx+1;
%         end
%     end
%     spp_array = strcat(spp_array(:,1),',',spp_array(:,2));
%     spp_array = unique(spp_array);
%     spp_array = num2cell(spp_array);
%     spp_count = length(spp_array);
%     
%     call_cells = cell(spp_count,1);
%     fillcells = cellfun('isempty',call_cells);
%     call_cells(fillcells) = {{'all'}};
%     
% end





% Free input Section

%%%%CREATE DATA STRUCTURES FOR DETECTION QUERIES%%%%
%Preallocate structure with appropriate fields
quer_count = 0;
call_count = 0;
info.effIdx = [];

%Grab effort from Tethys for each spp structure

info.spp(length(spp_cells)) = struct('ID','');

for spidx=1:spp_count
    info.spp(spidx).ID = spp_cells{spidx};
    info.spp(spidx).Site(site_count)=struct('Name','');
    info.spp(spidx).Calls = struct('Name','','Subtype','');
    cidx = 1; %loop index
    call_counter = 1;%loop counter
    while cidx<=length(call_cells{spidx})
        switch call_cells{spidx}{cidx}
            case 'Subtype'
                info.spp(spidx).Calls(call_counter-1).Subtype = call_cells{spidx}{cidx+1};
                cidx = cidx+2;
            otherwise
                info.spp(spidx).Calls(call_counter).Name = call_cells{spidx}{cidx};
                cidx = cidx+1;
                call_counter = call_counter+1;
                call_count = call_count+1;
        end
    end
end

num_queries = site_count*depl_count*call_count; %crossproduct of possible queries based on input
num_plots = call_count * site_count;
plotIdx = 1; %keeps track of which plot data will be added to


info.efforts{num_queries} = [];

queries(num_queries)=struct('Site','','Deployment',0,'SpeciesID','',...
    'Call','','Group','','Subtype','','Detections',[],'DetCount',0);
plots(num_plots) = struct('Site','','Deployments',[],'SpeciesID','','Group','',...
    'Call','','Subtype','','Effort',[],'Overlap',[],'Detections',[],...
    'days_of_data',[],'units_of_effort',[],'length_deployment',[],...
    'cum_hrs',[]);

fprintf('\n Executing %d Tethys queries..\n\n',num_queries);

for spidx=1:spp_count
    for cidx=1:length(info.spp(spidx).Calls)
        for sidx=1:site_count
            info.spp(spidx).Site(sidx).Name = site_cells{sidx};
            info.spp(spidx).Site(sidx).Deployment(depl_count) = struct('DeploymentID',0);
            fprintf('\n*** PLOT %d ***\n',plotIdx);
            plot_has_info = 0;%info flag for each plot
            %check how we're doing deployments before looping
            if isempty(deployment_array)
                depl_count = length(depl_cells{sidx});
            end
            for didx=1:depl_count
                if isempty(deployment_array)
                    info.spp(spidx).Site(sidx).Deployment(didx).DeploymentID = depl_cells{sidx}(didx);
                else
                    info.spp(spidx).Site(sidx).Deployment(didx).DeploymentID = deployment_array(didx);
                end
                
                quer_count = quer_count + 1;
                queries(quer_count).Site = info.spp(spidx).Site(sidx).Name;
                queries(quer_count).Deployment = info.spp(spidx).Site(sidx).Deployment(didx).DeploymentID;
                queries(quer_count).SpeciesID = info.spp(spidx).ID;
                if grouped
                    queries(quer_count).Group = group;
                end
                queries(quer_count).Call = info.spp(spidx).Calls(cidx).Name;
                if ~isempty(info.spp(spidx).Calls(cidx).Subtype)
                    queries(quer_count).Subtype = ...
                        info.spp(spidx).Calls(cidx).Subtype;
                    subbed = 1; %set subtype flag
                end
                if strcmpi(queries(quer_count).Call,'all')
                    all = 1;
                end
                
                disp(datestr(now));
                if ~grouped
                    fprintf('Query %d: %s%02d%s - %s %s.%s %s\n',quer_count,project,...
                        queries(quer_count).Deployment, queries(quer_count).Site,...
                        num2str(queries(quer_count).SpeciesID),queries(quer_count).Call,...
                        queries(quer_count).Subtype, granularity);
                else
                    fprintf('Query %d: %s%02d%s - %s.%s %s.%s %s\n',quer_count,project,...
                        queries(quer_count).Deployment, queries(quer_count).Site,...
                        num2str(queries(quer_count).SpeciesID),queries(quer_count).Group,...
                        queries(quer_count).Call,queries(quer_count).Subtype,...
                        granularity);
                end
                if ~plot_has_info
                    plots(plotIdx).Site = queries(quer_count).Site;
                    plots(plotIdx).SpeciesID = queries(quer_count).SpeciesID;
                    plots(plotIdx).Call = queries(quer_count).Call;
                    if subbed
                        plots(plotIdx).Subtype = queries(quer_count).Subtype;
                    end
                    plot_has_info = 1;
                end
                
                %%%%%GET THE EFFORT FOR THIS SITE+DEPL+SP+CALL%%%
                if ~document
                    iseff = 1;
                    if ~binned
                        if subbed && ~grouped
                            info.efforts{quer_count} = ...
                                dbGetEffort(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,'SpeciesID',...
                                queries(quer_count).SpeciesID,'Call',...
                                queries(quer_count).Call,'Subtype',...
                                queries(quer_count).Subtype,...
                                'Granularity',granularity);
                        elseif all && ~grouped
                            info.efforts{quer_count} = ...
                                dbGetEffort(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,'SpeciesID',...
                                queries(quer_count).SpeciesID,...
                                'Granularity',granularity);
                        elseif subbed && grouped
                            info.efforts{quer_count} = ...
                                dbGetEffort(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,'SpeciesID',...
                                queries(quer_count).SpeciesID,'Group',...
                                queries(quer_count).Group,'Call',...
                                queries(quer_count).Call,'Subtype',...
                                queries(quer_count).Subtype,...
                                'Granularity',granularity);
                        elseif all && grouped
                            info.efforts{quer_count} = ...
                                dbGetEffort(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,'SpeciesID',...
                                queries(quer_count).SpeciesID,'Group',...
                                queries(quer_count).Group, 'Granularity',granularity);
                        elseif grouped
                            info.efforts{quer_count} = ...
                                dbGetEffort(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,'SpeciesID',...
                                queries(quer_count).SpeciesID,'Call',...
                                queries(quer_count).Call,'Group',...
                                queries(quer_count).Group,'Granularity',granularity);
                        else
                            info.efforts{quer_count} = ...
                                dbGetEffort(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,'SpeciesID',...
                                queries(quer_count).SpeciesID,'Call',...
                                queries(quer_count).Call,...
                                'Granularity',granularity);
                        end
                    else
                        %% its binned, run different queries....
                        if subbed
                            info.efforts{quer_count} = ...
                                dbGetEffort(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,'SpeciesID',...
                                queries(quer_count).SpeciesID,'Call',...
                                queries(quer_count).Call,'Subtype',...
                                queries(quer_count).Subtype,...
                                'Granularity',granularity,'BinSize_m',binsize_m);
                        elseif all
                            info.efforts{quer_count} = ...
                                dbGetEffort(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,'SpeciesID',...
                                queries(quer_count).SpeciesID,...
                                'Granularity',granularity,'BinSize_m',binsize_m);
                        else
                            info.efforts{quer_count} = ...
                                dbGetEffort(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,'SpeciesID',...
                                queries(quer_count).SpeciesID,'Call',...
                                queries(quer_count).Call,...
                                'Granularity',granularity,'BinSize_m',binsize_m);
                        end
                    end
                else
                    info.efforts{quer_count} = doc_eff;
                end
                
                %if ~isempty(info.efforts{quer_count})
                plots(plotIdx).Effort = [plots(plotIdx).Effort; info.efforts{quer_count}];
                %end
                [x,y] = size(info.efforts{quer_count});
                if x*y > 2
                    fprintf('Multiple Efforts Detected (short breaks will be truncated)\n')
                    for i =1:x
                        fprintf('Range %d: %s  to  %s\n',i,...
                            datestr(info.efforts{quer_count}(i,1)),...
                            datestr(info.efforts{quer_count}(i,2)));
                    end
                    plots(plotIdx).Deployments(didx,1) = queries(quer_count).Deployment;
                    fprintf('\n');
                elseif x*1 ==1
                    fprintf('Effort Range: %s  to  %s\n\n', ...
                        datestr(info.efforts{quer_count}(1,1)),...
                        datestr(info.efforts{quer_count}(1,2)));
                    plots(plotIdx).Deployments(didx,1) = queries(quer_count).Deployment;
                elseif x*y == 0
                    fprintf('***No Effort Found for Query %d\n\n',quer_count);
                    iseff=0;
                end
                %pause(0.5);
                
                %%%%GRAB DETECTIONS IF THERE WAS EFFORT%%%%
                if iseff
                    if ~binned
                        if subbed && ~grouped
                            queries(quer_count).Detections = ...
                                dbGetDetections(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,...
                                'SpeciesID',queries(quer_count).SpeciesID,'Call',...
                                queries(quer_count).Call,'Subtype',...
                                queries(quer_count).Subtype,...
                                'Granularity',granularity);
                            
                        elseif all && ~grouped
                            queries(quer_count).Detections = ...
                                dbGetDetections(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,...
                                'SpeciesID',queries(quer_count).SpeciesID,...
                                'Granularity',granularity);
                        elseif subbed && grouped
                            queries(quer_count).Detections = ...
                                dbGetDetections(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,...
                                'SpeciesID',queries(quer_count).SpeciesID,'Call',...
                                queries(quer_count).Call,'Subtype',...
                                queries(quer_count).Subtype,'Group',...
                                queries(quer_count).Group,'Granularity',granularity);
                        elseif all && grouped
                            queries(quer_count).Detections = ...
                                dbGetDetections(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,...
                                'SpeciesID',queries(quer_count).SpeciesID,...
                                'Group',queries(quer_count).Group,...
                                'Granularity',granularity);
                        elseif grouped
                            queries(quer_count).Detections = ...
                                dbGetDetections(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,'SpeciesID',...
                                queries(quer_count).SpeciesID,'Call',...
                                queries(quer_count).Call,'Group',...
                                queries(quer_count).Group,'Granularity',granularity);
                        else
                            queries(quer_count).Detections = ...
                                dbGetDetections(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,...
                                'SpeciesID',queries(quer_count).SpeciesID,'Call',...
                                queries(quer_count).Call,'Granularity',granularity);
                        end
                    else
                            %% binned query, setting to hourly bin detections
                            %only
                            if subbed
                                queries(quer_count).Detections = ...
                                    dbGetDetections(queryEng,'Project',project,'Site',...
                                    queries(quer_count).Site,'Deployment',...
                                    queries(quer_count).Deployment,...
                                    'SpeciesID',queries(quer_count).SpeciesID,'Call',...
                                    queries(quer_count).Call,'Subtype',...
                                    queries(quer_count).Subtype,...
                                    'Granularity',granularity,'BinSize_m',60);
                            elseif all
                                queries(quer_count).Detections = ...
                                    dbGetDetections(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,...
                                'SpeciesID',queries(quer_count).SpeciesID,...
                                'Granularity',granularity,'BinSize_m',60);
                        else
                            queries(quer_count).Detections = ...
                                dbGetDetections(queryEng,'Project',project,'Site',...
                                queries(quer_count).Site,'Deployment',...
                                queries(quer_count).Deployment,...
                                'SpeciesID',queries(quer_count).SpeciesID,'Call',...
                                queries(quer_count).Call,'Granularity',...
                                granularity,'BinSize_m',60);
                        end
                    end
                    
                    if isempty(queries(quer_count).Detections)
                        fprintf('***No Detections for query: %d\n\n',quer_count);
                    else
                        switch(granularity)
                            case {'encounter'}
                                plots(plotIdx).Detections = [plots(plotIdx).Detections; queries(quer_count).Detections];
                                %Get Duty Cycle info
                                interval = 0;
                                duration = 0;
                                dep_info = dbDeploymentInfo(queryEng,'Project',project,...
                                    'DeploymentID',queries(quer_count).Deployment,...
                                    'Site',queries(quer_count).Site);
                                interval = dep_info.SamplingDetails.Channel.DutyCycle.Regimen.RecordingInterval_m;
                                duration = dep_info.SamplingDetails.Channel.DutyCycle.Regimen.RecordingDuration_m;
                                %in hours rather than minutes
                                plots(plotIdx).DutyInterval_h = interval/60; 
                                plots(plotIdx).DutyDur_h = duration/60;
                            case 'binned' %it is binned, handle the bins
                                starts = queries(quer_count).Detections(:,1);
                                starts_vec = datevec(starts);
                                %Remove the minutes and seconds from the start hour
                                starts_vec(:,5:6) = 0;
                                plots(plotIdx).Detections = [plots(plotIdx).Detections; datenum(starts_vec)];
                            case 'call'
                                %duplicate start times in 2nd column
                                queries(quer_count).Detections(:,2) = queries(quer_count).Detections(:,1);
                                plots(plotIdx).Detections = [plots(plotIdx).Detections; queries(quer_count).Detections];
                        end
                    end
                    
                    queries(quer_count).DetCount =...
                        length(queries(quer_count).Detections);
                   
                    %pause(0.5);
                    
                end
            end %deployment loop end
            if binned
                %loop in the end hour
                for ridx = 1:length(plots(plotIdx).Detections)
                    plots(plotIdx).Detections(ridx,2) = addtodate(...
                        plots(plotIdx).Detections(ridx,1),binsize_m,'minute');
                end
            end
            %finished deployments for that site, next plot for next site
            plotIdx = plotIdx+1;
        end
    end
end


%organize into columns
info.efforts = info.efforts';
%%%Population finished. Index which queries we will plot%%
for i=1:length(info.efforts)
    if ~isempty(info.efforts{i})
        info.effIdx = [info.effIdx i];
    end
end

%%%break out if no detections%%

if isempty(info.effIdx)
    disp('No Effort and/or Detections found for this inquiry');
    return;
end

%%%%%DETERMINE START/STOP OF GRAPH BASED ON EFFORT RETURNED%%%%%

startnums = [];%matrix of start datenums
endnums = [];%same as above for end times

for eidx = info.effIdx
    %populate matrix of start times
    %if you get index errors here, probably means effort start/end is
    %missing
    startnums = [startnums; info.efforts{eidx}(:,1)];
    endnums = [endnums; info.efforts{eidx}(:,2)];
end

allnums = [startnums;endnums];
%%%save the years to make subplots if desired%%%

years = unique(year(allnums));

%%%dono wat to use these for yet%%%
earliest_start = min(startnums);
latest_end = max(endnums);

xstart = floor(earliest_start);
xstop = ceil(latest_end);

%%%rearrange start/stop for proper year%%
startvec = datevec(xstart);
endvec = datevec(xstop);
startvec(3) = 1; % pad to first of the month
%pad until end of month
%only do this if the plot ends on a not-first-of-month
if endvec(3)~=1
    endvec(3) = eomday(endvec(1),endvec(2));
end



pstart= datenum(startvec);      %earliest date
pstop = datenum(endvec);     %latest date

dif = pstop-pstart;
weeks = ceil(dif/7);
days = weeks*7;
pstop = pstart + days +7;%pad an extra week...

if start
    pstart = usr_start;
end
if stop
    pstop = usr_stop;
end

if sub_yr
    pstart = datenum([years(1) 01 01 0 0 0]);
end


fprintf('Plot Start: %s\n',datestr(pstart));
fprintf('Plot End: %s\n\n',datestr(pstop));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(plots)
    
    
    %%%check for overlap here....store overlap into variable for later
    %%%plotting
    
    current = plots(i).Effort;
    if ~isempty(current)
        current = sortrows(current,1);
        total = size(current,1);
        for j = total-1:-1:1
            uprLt = current(j,1);
            lwrLt = current(j+1,1);
            uprRt = current(j,2);
            lwrRt = current(j+1,2);
            isOverlap = (lwrLt <= uprRt + 0.0375);
            if isOverlap
                %resource heavy?
                plots(i).Overlap = intersect([floor(uprLt):floor(uprRt)],...
                    [floor(lwrLt):floor(lwrRt)]);
                if uprRt < lwrRt
                    current(j,2) = current(j+1,2);
                end
                current(j+1,:) = [];
            end
        end
    end
    plots(i).Effort = current;

    %days_of_data=[];
    %hours_of_effort=[];
    for a=1:size(plots(i).Effort,1)
        clear days_of_deployment
        clear hours_per_day
        effort = plots(i).Effort;
        days_of_effort=floor(effort(a,1)):floor(effort(a,2)); %vector of all recording days
        %sometimes effort restarts where effort ends (the same day)
        %need to accouunt for that, i.e., merge days by comparing
        if a>1 && plots(i).days_of_data(end) == days_of_effort(1)
            days_of_effort = days_of_effort(2:end);
        end
        hours_per_day = ones(length(days_of_effort),1)*24;
        hours_per_day(1) = 24-((effort(a,1) - floor(effort(a,1)))*24);
        hours_per_day(end) = (effort(a,2) - floor(effort(a,2)))*24;
        %incorporate duty cycle into hours per day
        if strcmp(granularity,'encounter')
        if plots(i).DutyDur_h >0
            intervals_per_day = hours_per_day / plots(i).DutyInterval_h;
            %actual hours spent recording
            hours_per_day = intervals_per_day * plots(i).DutyDur_h;
        end
        end
        plots(i).units_of_effort=[plots(i).units_of_effort;hours_per_day];
        plots(i).days_of_data=[plots(i).days_of_data days_of_effort];
        plots(i).length_deployment(a) = length(days_of_effort);
    end
end



%% Organize Data into desired time units
% This section depends on
% speciesname,      array of strings with species names
% species_index,    array of integers indicating indicies of detections
% matdatestr,       cell array of start times and end times as strings
% days_of_data,    cell array with the days of effort
% matlabDates,      The times of detections in matlab time
% length_deployment, number of days for this deployment
% hours_of_effort, total hours of effort for this deployment (?)

% This section outputs
%   spdatenums,         a cell array with all the start and stop times
%   perdayscaled,       a cell array with only days with nonzero counts
%   days_of_data2,      a cell array with everyday and their counts


%Initialize cell arrays representing the number of successful queries
info.days_of_data2 = cell(length(plots),1);
info.perdayscaled = cell(length(plots),1);


%  Process overlapping entries. If two entries intersect, remove one
%  and take the union of the two as the resulting entry.
for i = 1:length(plots)
    current = plots(i).Detections;
    if ~isempty(current)
        current = sortrows(current,1);
        total = size(current,1);
        for j = total-1:-1:1
            s1 = current(j,1);
            s2 = current(j+1,1);
            f1 = current(j,2);
            f2 = current(j+1,2);
            isOverlap = (s2 <= f1);
            if isOverlap
                if f1 < f2
                    current(j,2) = current(j+1,2);
                end
                current(j+1,:) = [];
            end
        end
    end
    plots(i).Detections = current;
end


for pidx=1:length(plots); %plot index for queries struct
    
    %Remove plot if there was no effort
    if isempty(plots(pidx).Effort)
        continue;
    end
    
    n = 1;  % loop count index
   
    
    plots(pidx).min_date = pstart;      %earliest date
    plots(pidx).max_date = pstop;     %latest date
    
    %process detections if they exist..
    if ~isempty(plots(pidx).Detections)
        starttimes_n = []; %storage for summed times
        k =1;
        idx = 1;
        %find elapsed time, anything under 1 minute is rounded up to 1 min.
        %Do this only for non-call detections
        if ~calls
            spdatediff = bsxfun(@minus,(plots(pidx).Detections(:,2)), (plots(pidx).Detections(:,1)));
            
            for itr=1:length(spdatediff)
                if spdatediff(itr)<=.0007
                    spdatediff(itr)=.0007;
                end
            end
            
            
            % Add up all bouts that happened on the same julian day - this is GMT.
            starttimes=floor(plots(pidx).Detections(:,1));
            
            while idx<=length(starttimes)
                same_days =[];
                same_days = find (starttimes == starttimes(idx));
                starttimes_n(k,1)= starttimes(idx);
                starttimes_n(k,2)= sum(spdatediff(same_days));
                k=k+1;
                idx=max(same_days)+1;
            end
        else
            starttimes=floor(plots(pidx).Detections(:,1));
            while idx<=length(starttimes)
                same_days =[];
                same_days = find (starttimes == starttimes(idx));
                starttimes_n(k,1)= starttimes(idx);
                starttimes_n(k,2)= length(same_days);
                k=k+1;
                idx=max(same_days)+1;
            end
        end
    end

    % this part makes sure days where no detections were made are still
    % incorporated in the plot
    info.days_of_data2{pidx}=zeros(length(plots(pidx).days_of_data),2);
    info.days_of_data2{pidx}(:,1)= plots(pidx).days_of_data(:);
    
    %more detection manipulation
    if ~isempty(plots(pidx).Detections)
        if calls
            info.perdayscaled{pidx}=[starttimes_n(:,1), starttimes_n(:,2)]; % turn the number into calls per day?
        else
            info.perdayscaled{pidx}=[starttimes_n(:,1), starttimes_n(:,2)*24]; % turn the number into hours per day.
        end
        % Organizes all days into one array. days_of_data2 is assumed to be
        % sequential
        days_with_hits = size(info.perdayscaled{pidx},1);
        for i = 1:days_with_hits
            index = find(info.days_of_data2{pidx}(:,1) == info.perdayscaled{pidx}(i,1));
            if size(index,1) == 1
                info.days_of_data2{pidx}(index,2) = info.perdayscaled{pidx}(i,2);
            else
                disp(['Inconsistent data. Multiple or 0 entries for a day, plot=',num2str(pidx),', i=',num2str(i)]);
                return
            end
        end
    end
    info.days_of_data2{pidx}(:,3) = plots(pidx).units_of_effort;
    %info.days_of_data2{pidx}(:,4) = (info.days_of_data2{pidx}(:,2)./info.days_of_data2{pidx}(:,3))*100;
    
    %For encounters spanning >24 hours, carry excess into the next
    %day. Do this by iterating through the array, looking for >24. Subtract
    % 24 from that value, store it, and add it to the next row's cell.
    if strcmp(granularity,'encounter')
        for i = 1:length(info.days_of_data2{pidx})
            hours_that_day = info.days_of_data2{pidx}(i,2);
            if hours_that_day>24
                disp('***WARNING: >24 hours detected in a day***')
                info.days_of_data2{pidx}(i,2) = 24;
                excess = hours_that_day - 24;
                %add excess to the next day
                info.days_of_data2{pidx}(i+1,2) = info.days_of_data2{pidx}(i+1,2) + excess;
            end
        end
    end
    
    
    
    
    % Fill in missing days between deployments
    currentdata = info.days_of_data2{pidx};
    
    %fill in time before deployment (for N)
    currentdata_ext = floor(plots(pidx).min_date):floor(plots(pidx).Effort(1,1))-1;
    currentdata_ext = currentdata_ext';
    if ~isempty(currentdata_ext)
        currentdata_ext(:,2:3) = 0;
        %fill in first deployment
        first = currentdata(1:plots(pidx).length_deployment(1),:);
        currentdata_ext = [currentdata_ext;first];
    else 
        currentdata_ext = currentdata(1:plots(pidx).length_deployment(1),:);
    end
        %fill in gaps and further deployments
    for a=1:size(plots(pidx).Effort,1)-1
        clear days_between_deployments
        effort = plots(pidx).Effort;
        days_between_deployments=[ceil(effort(a,2)):1:floor(effort(a+1,1))-1]; %vector of all recording days
        days_between_deployments = days_between_deployments';
        days_between_deployments(:,2:3) = 0;
        currentdata_ext = [currentdata_ext;days_between_deployments];
        start = sum(plots(pidx).length_deployment(1:a))+1;
        stop = sum(plots(pidx).length_deployment(1:a+1));
        currentdata_ext = [currentdata_ext;...
            currentdata(start:stop,:)];
    end
        %fill in time after last deployment
    emptyEnd = currentdata_ext(end,1)+1:plots(pidx).max_date;
    emptyEnd = emptyEnd.';
    emptyEnd(:,2:3) = 0;
    currentdata_ext = [currentdata_ext;emptyEnd];
    
    %remove times after max_date
    indices = find(currentdata_ext(:,1)>plots(pidx).max_date);
    if ~isempty(indices)
        currentdata_ext(indices(1):indices(end)) = [];
    end

        
    info.days_of_data2{pidx} = currentdata_ext;
    n = n+1;
end

%% Y axis calculations
% Y axis should be constant across sites for given sp
% But, should change for different sp
%to achieve this, I create a m by n matrix, where
%   m = No. of input species
%   n = No. of successful queries, plus 1
% each row of the matrix represents a species
% each column represents a successful query, and the last column (+1) is
% reserved for the maximum cum. hours per week for that species.
% we will try to match the successful queries with input spp, and when we
% find a match, that query's index will be stored in the matrix. Then, once
% a row is processed, it will determine the max hours from all queries
% within that row, store it, and retrieve it when plotting.

%I really think this is overly complicated. Need more experience....


%%%%%%%%%%%%%%%%%%i actually do need this, species should have same maxY
shared_max = zeros(length(spp_cells),site_count+1);%matrix to hold plot indices


if ~document
    for spidx = 1:length(spp_cells)%loop through input spp
        n=1;
        for pidx=1:length(plots)
            if strcmp(spp_cells{spidx},plots(pidx).SpeciesID) %check if
                shared_max(spidx,n) = pidx;
                n = n+1;
            end
        end
    end
else
    for spidx = 1:length(spp_cells)%loop through input spp
        n=1;
        for pidx=1:length(plots)
            if spp_cells{spidx}==plots(pidx).SpeciesID %check if
                shared_max(spidx,n) = pidx;
                n = n+1;
            end
        end
    end
end


% shared_max now filled with successful queries. Let's do perweek stuff
for spp_row = 1:size(shared_max,1)
    sharing = nonzeros(shared_max(spp_row,:))';
    sp_hrs_all = [];
    if ~isempty(sharing) % we only want to do this on spp with data
        for pidx = sharing
%             if isempty(plots(pidx).Detections)
%                 continue;
%             end
            data = info.days_of_data2{pidx};
            num_of_weeks = ceil(size(data,1)/7);
            plots(pidx).cum_hrs = zeros(num_of_weeks,1);
            
            for i = 1:num_of_weeks
                % Use the first day of the week to identify the week
                first_day = 7*(i-1) + 1;
                last_day = min(first_day + 6, size(data ,1));
                plots(pidx).week(i,1) = data(first_day,1);
                plots(pidx).cum_hrs(i,1) = sum(data(first_day:last_day,2));
                plots(pidx).pcnt_eff(i,1) = (sum(data(first_day:last_day,3)))/(7*24)*100;
            end
            
            sp_hrs_all = [sp_hrs_all; plots(pidx).cum_hrs];
            
        end
        
        if ~isempty(sp_hrs_all)
            shared_max(spp_row, end) = max(sp_hrs_all);%store max for that spp in matrix
        end

        %loop (again) thru those sharing this maxvalue, and assign it
        for yidx = sharing
            if ~usr_max         
            plots(yidx).maxY = shared_max(spp_row, end);
            else           
                plots(yidx).maxY = yMax;        
            end
        end
    end
end

%% Plotting
%  This section depends on
%   spdatenums,         an cell array with all the start and stop times
%   days_of_data2,      an cell array with everyday and their counts
%   speciesname,        a cell array with species names as strings

for n=1:length(plots);
    
    data=info.days_of_data2{n};
    
    if isempty(data)
        continue;
    else
        %prepare for plotting
        site = plots(n).Site;
        species = num2str(plots(n).SpeciesID);
        call = plots(n).Call;
        subtype = plots(n).Subtype;
        deployments = num2str(plots(n).Deployments(:,1)','%d.');
        
        
        %instead of Figure
        if isempty(subtype)
            title = sprintf('Plot %d: %s%s%s - %s - %s', ...
                n, project,deployments, site, species, call);
        else
            title = sprintf('Plot %d: %s%s%s - %s - %s.%s', ...
                n, project,deployments, site, species, call,subtype);
        end
        if length(years)>1 && sub_yr
           rect = [0, 0, 1200, 200*length(years)];
        else
            rect = [0,0,1200,250];
        end

        figh = figure('NumberTitle','off', ...
           'Name',title,'Position',rect,'Units','Pixel');
        
       hold on
        
        

        if sub_yr
            for yidx=1:length(years)
                first_day = datenum([years(yidx) 1 1 0 0 0]);
                last_day = first_day+364;%first of yr to last of yr
                %ax=subplot(length(years),1,yidx);
                figh = figure('NumberTitle','off', ...
            'Name',title,'Position',rect,'Units','Pixel');
        hold on
                visWeeklyPlot(plots(n),data,granularity,'First',first_day,...
                    'Last',last_day,'Years',years);
            end
            
            Shared Axes Label
            if length(years)>1
                ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],...,
                    'Box','off','Visible','off','Units','normalized', 'clipping', 'off');
                text(0.0625,0.5,'Cumulative Hours per Week','HorizontalAlignment',...
                    'left', 'rotation',90,'FontSize',12)
                text(0.9375,0.5,'Percentage of Effort per Week','HorizontalAlignment',...
                    'left', 'rotation',90,'FontSize',12)
            end
        else
            visWeeklyPlot(plots(n),data,granularity);
        end
    end
    if save
        %try to save file
        save_path=strcat(path,species,'\');
        if ~isdir(save_path)
            mkdir(save_path);
        end
        fname = sprintf('%s%s%s%s_%s_%s_%s.jpg',save_path,project,deployments,site,species,call,subtype);
        set(figh,'PaperPositionMode','auto')
        print(figh,'-djpeg',fname,'-r0')
    end
end
