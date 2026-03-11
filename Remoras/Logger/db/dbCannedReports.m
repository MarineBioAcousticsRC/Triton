function summary = dbCannedReports(queries, detector, bycall, statfile)
% summary = dbCannedReports(queries, detector)
% Generate reports from Tethys database
% detector - one of 'human', 'sbp_rule', 'hr_click'
% bycall - false: species level only, true: break down by call type
% statfile - [] or filename where summary statistics are written

project = 'SOCAL';
EffortSpanPrev = [];
diel = true;
savefigs = true;
night = [];  % prime in case diel is false

figH = [];
% Hard code this to a list of species to restrict 
% processing to only the specified species. 
% i.e. {'Gg', 'Lo'} Risso's and Pacific white-sided only
onlySpecies = [];
%onlySpecies = {'Mn'};

% Open log file for statistics.
% Outputs are written in comma separated value format,
% suitable for import into Excel, mailmerge, etc.
if ~ isempty(statfile)
    statH = fopen(statfile, 'w');
    if statH == -1
        error('Unable to open statfile')
    end
    % Write column titles
    fprintf(statH, ['Name,Presence h,Presence%% h, Effort h,', ...
        'Presence d,Presence%% d, Effort d\n']);

else
    statH = [];
end

for sitecell = {'M', 'N'}
    site = sitecell{1};  % Get copy without cell array
    % find deployments associated with this project and site
    deploy_str = queries.Query(sprintf(...
        ['distinct-values(collection("Detections")/', ...
        'Detections[Site = "%s" and Project="%s"]/Deployment)'], ...
        site, project));
    % parse deployment string, char(.) needed as Query returns a
    % Java string that Matlab cannot handle.
    deployments = sscanf(char(deploy_str), '%d')';
    for deploy = deployments
        % find species for which we have effort
        [effort, details] = dbGetEffort(queries, ...
            'Site', site, 'Deployment', deploy, 'Project', project, ...
            'Detector', detector);
        if isempty(effort)
            fprintf('Skipping deployment %d site %s - no %s effort\n', ...
                deploy, site, detector)
            continue
        end
        % retrieve deployment record
        sensor = dbDeploymentInfo(queries, 'Project', project, ...
            'Deployment', deploy, 'Site', site);
        % by species
        species = unique({details.Species});
        for scell = species
            s = scell{1};  % Get copy without cell array
            
            if ~isempty(onlySpecies)
                if ~ismember(s, onlySpecies)
                    fprintf('Skipping %s site %d%s: %s\n', ...
                        project, deploy, site, s);
                    continue
                end
            end
            
            % find which efforts are associated with this species
            speciesP = arrayfun(@(x) strcmp(x.Species, s), details);
            s_effort = effort(speciesP, :);
            
            if bycall
                % find calls associated with this species --------
                % call types present
                calls = unique({details(speciesP).Call_type});
            else
                calls = {[]};
            end
            
            for ccell = calls
                
                c = ccell{1};  % copy without cell array
                
                if ~isempty(c)
                    callP = arrayfun(@(x) ...
                        strcmp(x.Species, s) && strcmp(x.Call_type, c), ...
                        details);
                    % Retrieve detections
                    [s_detections, endP] = dbGetDetections(queries, ...
                        'Site', site, ...
                        'Deployment', deploy, 'Detector', detector, ...
                        'Species', s, 'Call_type', c);
                    % construct title
                    t = sprintf('%s%d%s - %s - %s', ...
                        project, deploy, site, s, c);
                else
                    % Set call predicate to species predicate
                    callP = speciesP;
                    [s_detections, endP] = dbGetDetections(queries, 'Site', site, ...
                        'Deployment', deploy, 'Detector', detector, 'Species', s);
                    % construct title
                    t = sprintf('%s%d%s - %s', ...
                        project, deploy, site, s);
                end
                c_effort = effort(callP, :);
                EffortSpan = [min(c_effort(:, 1)), max(c_effort(:, 2))];
                    
                fprintf('Processing %s %s from:\n', s, c); 
                fprintf('%s\n', details(callP).XML_Document);
                
                if size(s_detections, 2) > 1
                    if any(endP==0)
                        % contains combination of hourly & min
                        % detections, use coarser bin size
                        resolution = 60;
                        fprintf('Mixed start & start/end detections, using 1 h bins\n')
                    else
                        resolution = 1;
                    end
                else
                    resolution = 60;
                end

                if ~ isempty(figH)
                    close(figH);  % prevent millions of images...
                end
                figH= figure('Name', t);
                % Get diel information if different than previous one
                if ~isequal (EffortSpan, EffortSpanPrev) && diel
                    night = dbDiel(queries, ...
                        sensor.GeoTime.latitude, sensor.GeoTime.longitude, ...
                        EffortSpan(1), EffortSpan(2));
                end
                EffortSpanPrev = EffortSpan;
                % add diel information
                if ~ isempty(night)
                    nightH = visPresence(night, 'Color', 'black', ...
                        'LineStyle', 'none', 'Transparency', .15, ...
                        'Resolution_m', 1/60, 'DateRange', EffortSpan);
                end

                sightH = visPresence(s_detections, ...
                    'Resolution_m', resolution, 'LineStyle', 'none', ...
                    'Effort', c_effort, 'Label', t);
                
                % ugly code to fix up the filenames
                fname = sprintf('%s.jpg', strrep(t, ' - ', '-'));
                fname = strrep(fname, ' ', '');
                fname = regexprep(fname, '[/\\'']', '');
                fname = strrep(fname, '?', '-QuestionMark');
                
                set(gca, 'YDir', 'reverse');  %upside down plot
                if savefigs
                    print(figH, '-djpeg', fname);
                end
                
                % Generate report information if needed
                if ~ isempty(statH)
                    % Find number of presences for each hour
                    Presence_h = dbPresenceAbsence(s_detections, ...
                        'Resolution_m', 60, 'Output', 'counts');
                    HoursPresent = sum(Presence_h);
                    % Find number of possible hours
                    Effort_h = dbPresenceAbsence(c_effort, ...
                        'Resolution_m', 60, 'Output', 'counts');
                    HoursEffort = sum(Effort_h);
                    % Presence in daily bins
                    DaysPresent = dbPresenceAbsence(s_detections, ...
                        'Resolution_m', 60*24, 'Output', 'counts');
                    DaysEffort = dbPresenceAbsence(c_effort, ...
                        'Resolution_m', 60*24, 'Output', 'counts');
                    % The %.1f should be %d (decimal), but we'll leave them as
                    % floating point for now, just so we can see if there
                    % are errors
                    fprintf(statH, '%s,%.1f,%.2f,%.1f,%.1f,%.2f,%.1f\n', ...
                        t, HoursPresent, HoursPresent/HoursEffort*100, HoursEffort, ...
                        DaysPresent, DaysPresent/DaysEffort*100, DaysEffort);
                end
                
                
            end  % end call type
        end
    end
end

if ~ isempty(statH)
    fclose(statH);
end


    
