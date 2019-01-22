function dbYearlyReport(queries, detector, bycall, statfile)
% dbCannedReports(queries, detector)
% Generate reports from Tethys database
% detector - one of 'human', 'sbp_rule', 'hr_click'
% bycall - false: species level only, true: break down by call type

project = 'SOCAL';
EffortSpanPrev = [];
diel = true;
savefigs = true;
night = [];  % prime in case diel is false

if nargin < 4
    statfile = [];
end

figH = [];

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

for sitecell = {'M'}  %{'M', 'N'}
    site = sitecell{1};  % Get copy without cell array
    
    sensor = dbDeploymentInfo(queries, 'Project', project, ...
                    'Site', site);    
    % find species for which we have effort
                
    fprintf('Kludged effort - querying regardless of species\n');
    [effort, details] = dbGetEffort(queries, 'Project', project, ...
         'Deployment', {'>=', 32},'Site', site, 'Detector', detector);

    % by species
    species = unique({details.Species});
    
        for scell = species
            s = 'Anthro' %scell{1};  % Get copy without cell array
            
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
                if ~ isempty(figH)
                    close(figH);  % prevent millions of images...
                end
                
                c = ccell{1};  % copy without cell array
                
                if ~isempty(c)
                    callP = arrayfun(@(x) ...
                        strcmp(x.Species, s) && strcmp(x.Call_type, c), ...
                        details);
                    % Retrieve detections
                    [s_detections, endP] = dbGetDetections(queries, ...
                        'Site', site, 'Detector', detector, 'Species', s,...
                        'Deployment', {'>=', 32},'Call_type', c);
                    
                    % construct title
                    t = sprintf('%s%d%s - %s - %s - %s', ...
                        project, site, s, c, detector);
                else
                    % Set call predicate to species predicate
                    callP = speciesP;
                    [s_detections, endP] = dbGetDetections(queries, 'Site', site, ...
                        'Detector', detector, 'Species', s, ...
                        'Deployment', {'>=', 32});
                    % construct title
                    t = sprintf('%s-%s-%s-%s', project, site, s, detector);
                end
                c_effort = effort(callP, :);
%                 EffortSpan = [min(c_effort(:, 1)), max(c_effort(:, 2))];
                EffortSpan = [min(effort(:, 1)), max(effort(:, 2))];
                
                fprintf('Processing %s %s from:\n', s, c); 
                fprintf('%s\n', details(callP).XML_Document);
                
                if size(s_detections, 2) > 1
                    if ~isempty(find(endP==0))
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

                figH= figure('Name', t);
                % Get diel information if different than previous one
                if ~isequal (EffortSpan, EffortSpanPrev) && diel
                    latitude = sensor(1).GeoTime.latitude;
                    longitude = sensor(1).GeoTime.longitude;
                    fprintf('Using first deployment''s latitude:  %f and longitude %f\n', ...
                        latitude, longitude);
                
                    night = dbDiel(queries, ...
                        latitude, longitude, ...
                        EffortSpan(1), EffortSpan(2));
                end
%                 night = [];
                EffortSpanPrev = EffortSpan;
                
                % add diel information
                if ~ isempty(night)
                    nightH = visPresence(night, 'Color', 'black', ...
                        'LineStyle', 'none', 'Transparency', .15, ...
                        'Resolution_m', 1/60, 'DateRange', EffortSpan,...
                        'DateTickInterval',28);
                end

                sightH = visPresence(s_detections, ...
                    'Resolution_m', resolution, 'LineStyle', 'none', ...
                    'Effort', effort, 'Label', t,'DateTickInterval',28);
                
                % ugly code to fix up the filenames
                fname = sprintf('%s.fig', strrep(t, ' - ', '-'));
                fname = strrep(fname, ' ', '');
                fname = regexprep(fname, '[/\\'']', '');
                fname = strrep(fname, '?', '-QuestionMark');
                
                set(gca, 'YDir', 'reverse');  %upside down plot
                set(gca, 'YGrid', 'off');
                if savefigs
                    saveas(figH, fname, 'fig');
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
