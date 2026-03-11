function dbCannedReportsLoSubtype(queries)
% dbCannedReports(queries, detector)
% Generate reports from Tethys database
% detector - one of 'human', 'sbp_rule', 'hr_click'
% bycall - false: species level only, true: break down by call type

detector = 'human';
project = 'SOCAL';
EffortSpanPrev = [];
figH = [];
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
        for scell = {'Lo'}
            s = scell{1};  % Get copy without cell array
            % find which efforts are associated with this species
            speciesP = arrayfun(@(x) strcmp(x.Species, s), details);
            s_effort = effort(speciesP, :);
            c = 'Clicks';
            for subtypecell = {'A', 'B'}
                subtype = subtypecell{1};
                             
                callP = arrayfun(@(x) ...
                    strcmp(x.Species, s) && strcmp(x.Call_type, c), ...
                    details);
                % Retrieve detections
                [s_detections, endP] = dbGetDetections(queries, ...
                    'Site', site, ...
                    'Deployment', deploy, 'Detector', detector, ...
                    'Species', s, 'Call_type', c, ...
                    'Call_type/@Subtype', subtype);
                    
                % construct title
                t = sprintf('%s%d%s - %s - %s - %s', ...
                    project, deploy, site, s, c, subtype);
                if isempty(s_detections)
                    fprintf('No detections %s: skipping\n', t);
                    continue
                end

                c_effort = effort(callP, :);
                EffortSpan = [min(c_effort(:, 1)), max(c_effort(:, 2))];
                    
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
                
                if ~ isempty(figH)
                    close(figH);  % prevent millions of images...
                end
                figH = figure('Name', t);
                
                % Get diel information if different than previous one
                if ~isequal (EffortSpan, EffortSpanPrev)
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
                if ~ isempty(s_detections)
                    sightH = visPresence(s_detections, ...
                        'Resolution_m', resolution, 'LineStyle', 'none', ...
                        'Effort', c_effort, 'Label', t);
                end
                % ugly code to fix up the filenames
                fname = sprintf('%s.jpg', strrep(t, ' - ', '-'));
                fname = strrep(fname, ' ', '');
                fname = regexprep(fname, '[/\\'']', '');
                fname = strrep(fname, '?', '-QuestionMark');
                
                set(gca, 'YDir', 'reverse');  %upside down plot
                print(figH, '-djpeg', fname);
                
                1;
            end % end subtype
        end  % species
    end % deployment
end


    
