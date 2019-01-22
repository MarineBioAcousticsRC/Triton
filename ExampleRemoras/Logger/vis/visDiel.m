function plots = visDiel(queryEng, varargin)


%visDiel(queryEngine, arguments)
% Generate a plot of detections mapped against night/day diel information.
% Detections can be narrowed down by Call, call subtype, and or species
% Group. Multiple deployments for a given site can be appended to the same
% plot, but multiple sites will have their own plot.
%
%
% queryEng must be a Tethys database query object, see dbDemo() for an
% example of how to create one.
%
%
% Use the following keywords as a string, followed by the desired value.
%
% Required Input Arguments:
% 'Project', string - Name of project data is associated with, e.g. SOCAL
% 'Site', string - name of location where data was collected. For multiple
%          sites use a cell array, e.g. {'A','B','C'}
% 'Deployment', integer | array - Which deployment of sensor at a given
%         location. For multiple deployments, use an array, e.g. [1 2 3] or [1:3]
% 'SpeciesID' - species/family/order/... name.  Format depends on the last
%        call to dbSpeciesFmt. 
% 'Call' - type of call. To plot all calls use 'all'. For multiple calls,
%       use a cell array. E.g. {'Clicks','Whistles'}
% 'Granularity', string - Type of effort. Currently, binned granularity is
%  assumed to be HOURLY.
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
% 'UserID', string - restrict documents to a specific user
% 'Lunar', True | (False) - plot lunar illumination for the given
% deployment
%
%%%Others:
% 'Subtype', string - subtype of call. Must be used as within a cell array, e.g.
%       ...,'Call',{'Clicks','Subtype','<20kHz')
% 'Group', string - Species Group
% 'Xtick', integer - frequency of tick marks for the x axis (UTC hours, default 3)
% 'Ytick', integer - frequuency of y axis tick marks (Days, default 7 is weekly).
% 'Resolution', integer - how much definition, in minutes, per detection.
%    Default is 60, so a detection at 07:00 would have a bar spanning 7-8am.
% 'SaveTo', string - allows saving of a jpeg to the output path specified.
%
% Full Example:
%
% visWeeklyEffort(qb,'Project','SOCAL','Site',{'M','N','H','G2','E'},...
% 'Deployment',[31:51],'SpeciesID',{'Lo','Oo'},'Granularity','encounter',...
% 'Call',{{'Clicks'},{'Clicks','Whistles'}},'ByYear',true,...
% 'SaveTo','C:\users\seano\desktop\plots');
%






%%%%%%%%%%%%%%%%%%%%%%%%%%SET UP VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%Time Intervals for Axis%%%%
start = false; %default do not use user supplied dates
stop = false;
save=0;%default do not save
xtick = 3; %default 3
ytick = 7; %default 7
comment = false;
resolution=60; %hourly resolution
lunar = false;

vidx=1;
site_array={};
deployment_array={};
spp_array = {};
grouped = false;
subbed = false; %flag - does this query include a subtype?
%input counts
site_count = 0;
depl_count = 0;
call_count = 0;
spp_count = 0;

req_input = 0; %totals up required arguments, verifys total afterwards
%project,site,deployment,species
while vidx <= length(varargin)
    switch varargin{vidx}
        case 'Project'
            project = varargin{vidx+1};
            req_input = req_input+1;
            vidx = vidx+2;
        case 'Site'
            if iscell(varargin{vidx+1})
                site_array = varargin{vidx+1};
                site_count = length(site_array);
            else
                site_array = varargin(vidx+1);
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
                spp_array = varargin{vidx+1};
                spp_count = length(spp_array);
            else
                spp_array = varargin(vidx+1);
                spp_count = 1;
            end
            req_input = req_input+1;
            vidx = vidx+2;
        case 'Call'
            if iscell(varargin{vidx+1})
                call_cells = varargin{vidx+1};
                call_count = length(call_cells);
            else
                call_cells = {varargin(vidx+1)};
            end
            vidx = vidx+2;
        case 'Group'
            group = varargin{vidx+1};
            grouped = true; % flag
            vidx = vidx+2;            
        case 'Granularity'
            granularity = varargin{vidx+1};
            vidx=vidx+2;
            req_input = req_input+1;
        case 'Resolution'
            resolution = varargin{vidx+1};
            vidx=vidx+2;
        case 'XTick'
            xtick = varargin{vidx+1};
            vidx = vidx+2;
        case 'YTick'
            xtick = varargin{vidx+1};
            vidx = vidx+2;
        case 'Start'
            usr_start = varargin{vidx+1};
            start=true;
            vidx=vidx+2;
        case 'Comment'
            comment_str = varargin{vidx+1};
            comment = true;
            vidx = vidx+2;
        case 'End'
            usr_stop = varargin{vidx+1};
            stop = true;
            vidx=vidx+2;
        case 'Lunar'
            lunar = true;
            vidx = vidx+2;
        case 'SaveTo'
            path = varargin{vidx+1};
            save = true;
            vidx =vidx+2;            
        otherwise
            error('Bad arugment:  %s', varargin{idx});
            return;
    end
end

%If there is only once species, and multiple calls, put call cells into
%another cell for processing. Why must this be done? Because I am an
%amateur programmer.

if spp_count == 1 && call_count >1
    call_cells = {call_cells};
end
    



%Make sure all four required inputs have been input
if ~(req_input==5)
    error('Missing an Argument: Project, Deployment, Site, Granularity, SpeciesID');
end



%%%%CREATE DATA STRUCTURES FOR DETECTION QUERIES%%%%
%Each structure will be based on a spp, contained within larger struct
%called 'spp'. The structure will be broken down and passed to dbGetEffort
%as well as dbGetDetections.
%
%spp.ID = speciesID
%spp.Deployments = the deployments of interest
%spp.Calls = the calls of interest
%spp.
%Design flaw - nonexistent calls will still be queried for, e.g.
% ID = 'Oo', Call = 'Explosion'
%(though explosive Orcas are good to watch out for). As long as site
%project and deployments are entered, Performance will not suffer much (I
%hope)
%
%


%Preallocate structure with appropriate fields

info.detIdx = [];
info.spp(length(spp_array)) = struct('ID','');




%Grab effort from Tethys for each spp structure
%TODO--- these loops
quer_count = 0;
call_count = 0;
for spidx=1:spp_count
    info.spp(spidx).ID = spp_array{spidx};
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
info.plotIdx = [];

queries(num_queries)=struct('Site','','Deployment',0,'SpeciesID','',...
    'Call','','Subtype','','Group','','DetCount',0);
plots(num_plots) = struct('Site','','Deployments',[],'SpeciesID','',...
    'Call','','Subtype','','Effort',[],'Detections',[],'Lat',...
    0,'Lon',0,'NightTime',[],'cum_hrs',[]);

for spidx=1:spp_count
    for cidx=1:length(info.spp(spidx).Calls)
        for sidx=1:site_count
            info.spp(spidx).Site(sidx).Name = site_array{sidx};
            info.spp(spidx).Site(sidx).Deployment(depl_count) = struct('DeploymentID',0);
            fprintf('\n*** PLOT %d ***\n',plotIdx);
            plot_has_info = 0;%info flag for each plot
            %Check how we're doing deployments before looping
            if isempty(deployment_array)
                depl_count = length(depl_cells{sidx});
            end
            for didx=1:depl_count
                if isempty(deployment_array)
                    info.spp(spidx).Site(sidx).Deployment(didx).DeploymentID = depl_cells{sidx}(didx);
                else
                    info.spp(spidx).Site(sidx).Deployment(didx).DeploymentID = deployment_array(didx);
                end
                %Pause half a second between each query

                all=0;%flag - are we looking at all calls?
                quer_count = quer_count + 1;
                queries(quer_count).Site = info.spp(spidx).Site(sidx).Name;
                queries(quer_count).Deployment = info.spp(spidx).Site(sidx).Deployment(didx).DeploymentID;
                queries(quer_count).SpeciesID = info.spp(spidx).ID;
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
                if grouped
                    queries(quer_count).Group = group;
                    fprintf('Query %d: %s%d%s - %s.%s %s.%s %s\n',quer_count,project,...
                        queries(quer_count).Deployment, queries(quer_count).Site,...
                        queries(quer_count).SpeciesID,queries(quer_count).Group,...
                        queries(quer_count).Call,queries(quer_count).Subtype,...
                        granularity);
                else
                    fprintf('Query %d: %s%d%s - %s %s.%s %s\n',quer_count,project,...
                        queries(quer_count).Deployment, queries(quer_count).Site,...
                        queries(quer_count).SpeciesID,queries(quer_count).Call,...
                        queries(quer_count).Subtype, granularity);
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
                
                %%%%%SORT OUT THE EFFORT FOR THIS SITE+DEPL+SP+CALL%%%
                iseff = 1;
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
                
                plots(plotIdx).Effort = [plots(plotIdx).Effort; info.efforts{quer_count}];
                
                [x,y] = size(info.efforts{quer_count});
                if x*y > 2
                    fprintf('\nMultiple Efforts Detected \n')
                    for i =1:x
                        fprintf('Range %d: %s  to  %s\n',i,...
                            datestr(info.efforts{quer_count}(i,1)),...
                            datestr(info.efforts{quer_count}(i,2)));
                    end
                elseif x*1 ==1
                    fprintf('\nEffort Range: %s  to  %s\n\n', ...
                        datestr(info.efforts{quer_count}(1,1)),...
                        datestr(info.efforts{quer_count}(1,2)));
                elseif x*y == 0
                    fprintf('***No Effort Found for Query %d\n\n',quer_count);
                    iseff=0;
                end
                pause(0.5);
                
                %%%%IF THERE WAS EFFORT, GRAB MORE INFO, Detections%%%%
                if iseff
                    info.plotIdx = [info.plotIdx, plotIdx]; %index of plots
                    %Get lat/lon info
                    depl_info = dbDeploymentInfo(queryEng, 'Project',...
                        project,'Site', queries(quer_count).Site,...
                        'DeploymentID',queries(quer_count).Deployment);
                    if issempty(depl_info)
                        error('Cannot find deployment information for given inputs')
                    end
                    droplat = depl_info.DeploymentDetails.Latitude;
                    droplon = depl_info.DeploymentDetails.Longitude;
                    reclat = depl_info.RecoveryDetails.Latitude;
                    reclon = depl_info.RecoveryDetails.Longitude;
                    plots(plotIdx).Lat = (droplat+reclat)/2;
                    plots(plotIdx).Lon = (droplon+reclon)/2;
                    
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
                    elseif comment
                        queries(quer_count).Detections = ...
                            dbGetDetections(queryEng,'Project',project,'Site',...
                            queries(quer_count).Site,'Deployment',...
                            queries(quer_count).Deployment,...
                            'SpeciesID',queries(quer_count).SpeciesID,'Call',...
                            queries(quer_count).Call,'Granularity',granularity,'Comment',comment_str);
                    else
                        queries(quer_count).Detections = ...
                            dbGetDetections(queryEng,'Project',project,'Site',...
                            queries(quer_count).Site,'Deployment',...
                            queries(quer_count).Deployment,...
                            'SpeciesID',queries(quer_count).SpeciesID,'Call',...
                            queries(quer_count).Call,'Granularity',granularity);
                    end
                    
                    if isempty(queries(quer_count).Detections)
                        fprintf('***No Detections for query: %d\n\n',quer_count);
                    else
                        %Process granularities different
                        %binned assumes hourly bins,
                        %call assumes no end times
                        %visPresence uses hourly bins when end times absent
                        %so remove end times from 'call' and 'binned'
                        if strcmp(granularity,'binned')
                            %we got detections, lets manipulate them
                            starts = queries(quer_count).Detections(:,1);
                            starts_vec = datevec(starts);
                            %Remove the minutes and seconds from the start hour
                            starts_vec(:,5:6) = 0;
                            plots(plotIdx).Detections = [plots(plotIdx).Detections;datenum(starts_vec)];
                        elseif strcmp(granularity,'call')
                            %if the queried detections have end times,
                            %remove them
                            if size(queries(quer_count).Detections,2) >1 
                                queries(quer_count).Detections(:,2) = [];
                            end
                            plots(plotIdx).Detections = [plots(plotIdx).Detections;queries(quer_count).Detections];
                        else
                            plots(plotIdx).Detections = [plots(plotIdx).Detections; queries(quer_count).Detections];
                        end
                        plots(plotIdx).Deployments = [plots(plotIdx).Deployments queries(quer_count).Deployment];
                    end
                    
                    queries(quer_count).DetCount =...
                        length(queries(quer_count).Detections);
                    pause(0.5);
                    
                end
            end
            %finished deployments for that site, next plot for next site
            plotIdx = plotIdx+1;
        end
    end
end

if numel(info.efforts)==1 && isempty(info.efforts{1})
    disp('No Effort Found for input, exiting')
    return;
end

%organize into columns
queries = queries';
info.efforts = info.efforts';

%loop in end hours of binned detections
if strcmp(granularity,'binned')
    for pidx = 1:length(plots)
        for ridx = 1:length(plots(pidx).Detections)
            plots(pidx).Detections(ridx,2) = addtodate(...
                plots(pidx).Detections(ridx,1),60,'minute');
        end
    end
end



%%%%%%%%%%%DETERMINE START/STOP OF GRAPH BASED ON EFFORT RETURNED%%%%%%

startnums = [];%matrix of start datenums
endnums = [];%same as above for end times

for eidx = 1:length(info.efforts)
    %populate matrix of start times
    %if you get index errors here, probably means effort start/end is
    %missing
    if isempty(info.efforts{eidx})
        continue;
    end
    startnums = [startnums; info.efforts{eidx}(:,1)];
    endnums = [endnums; info.efforts{eidx}(:,2)];
end

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
else
    endvec(3) = 6;
end


pstart= datenum(startvec);      %earliest date
pstop = datenum(endvec);     %latest date

dif = pstop-pstart;
weeks = ceil(dif/7);
days = weeks*7;
pstop = pstart + days +7;%add an extra week...

%Hardcode option for plot start/end times
%pstart = ; plot start date
%pstop = datenum([2013 08 31 0 0 0]);  plot stop date
if start
    pstart = usr_start;
end
if stop
    pstop = usr_stop;
end



fprintf('Plot Start: %s\n',datestr(pstart));
fprintf('Plot End: %s\n\n',datestr(pstop));
start = pstart;
stop = pstop;

for pidx = info.plotIdx
    %Get Nighttime
    plots(pidx).NightTime = dbDiel(queryEng,...
        plots(pidx).Lat,plots(pidx).Lon,...
        start, stop);
end


for n=1:length(plots)
    
    %remove small breaks (<54 min) in effort...
    effort = plots(n).Effort;
    if ~isempty(effort)
        effort = sortrows(effort,1);
        total = size(effort,1);
        for j = total-1:-1:1
            f1 = effort(j,1);
            f2 = effort(j+1,1);
            s1 = effort(j,2);
            s2 = effort(j+1,2);
            isOverlap = (f2 <= s1 + 0.0375);
            if isOverlap
                if s1 < s2
                    effort(j,2) = effort(j+1,2);
                end
                effort(j+1,:) = [];
            end
        end
    else
        continue;
    end
    plots(n).Effort = effort;
    
    
    
    
    %prepare for plotting
    site = plots(n).Site;
    %deployment = plots(n).Deployments;
    species = plots(n).SpeciesID;
    call = plots(n).Call;
    subtype = plots(n).Subtype;
    deployments = num2str(plots(n).Deployments);
    

    %instead of Figure
    if grouped
        title = sprintf('Plot %d: %s%s%s - %s.%s - %s', ...
            n, project,deployments, site, species,group, call);
    elseif comment
        title = sprintf('Plot %d: %s%s%s - %s - %s.%s', ...
            n, project,deployments, site, species, call,comment_str);
	else
		title = sprintf('Plot %d: %s%s%s - %s - %s.%s', ...
				n, project,deployments, site, species, call,subtype);
    end
    rect = [0, 0, 500, 800];
    figh = figure('NumberTitle','off','Name',title,'Position',rect,...
        'Units','Pixel'); 
    % add diel information
    nightH = visPresence(plots(n).NightTime, 'Color', 'black', ...
        'LineStyle', 'none', 'Transparency', .15, ...
        'Resolution_m', 1/60,'DateTickInterval',ytick,...
        'DateRange', [start, stop], 'HourTickInterval',...
        xtick);
    
    if lunar
        illu = dbGetLunarIllumination(queryEng, droplat, droplon, plots(n).Effort(1), plots(n).Effort(2), 30);
        lunarH = visLunarIllumination(illu);
    end
    sightH = visPresence(plots(n).Detections, ...
        'Resolution_m', resolution,'DateTickInterval',ytick,...
        'LineStyle', 'none', 'DateRange', [start, stop],...
        'Effort', plots(n).Effort, 'Label', title,...
        'HourTickInterval', xtick);
    set(gca, 'YDir', 'reverse');  %upside down plot
    
    if save
        %try to save file
        fname = sprintf('%s%s_%s_%s_%s.jpg',path,site,species,call,subtype);
        set(figh,'PaperPositionMode','auto')
        print(figh,'-djpeg',fname,'-r0')
    end
                
                
end


