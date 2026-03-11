function dbStats(queries, detector, bycall)
% dbStats(queries, detector, bycall)
% Generate statistics on daily and hourly bins with calls and percentage 
% in regards to effort from Tethys database
% detector - one of 'human', 'sbp_rule', 'hr_click'
% bycall - false: species level only, true: break down by call type

project = 'SOCAL';
EffortSpanPrev = [];

for sitecell = {'M', 'N'}
    site = sitecell{1};  % Get copy without cell array
    
    for deploy = [32 33 34 35 36 37]
        
        % find species for which we have effort
        [effort, details] = dbGetEffort(queries, ...
            'Site', site, 'Deployment', deploy, 'Project', project, ...
            'Detector', detector);
        % retrieve deployment record
        sensor = dbDeploymentInfo(queries, 'Project', project, ...
            'Deployment', deploy, 'Site', site);
        % by species
        species = unique({details.Species});
        for scell = species
            s = scell{1};  % Get copy without cell array
            
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
                dayEffort = round(EffortSpan(2)-EffortSpan(1));
                hourEffort = round((EffortSpan(2)-EffortSpan(1))*24);
                    
                fprintf('Processing %s %s from:\n', s, c); 
                fprintf('%s\n', details(callP).XML_Document);
                
                %number of days with detections
                if size(s_detections,2)==2
                    days = [round(s_detections(:,1));round(s_detections(:,2))];
                    days = unique(days);
                    sumDays = length(days);
                else
                    days = round(s_detections);
                    days = unique(days);
                    sumDays = length(days);
                end
                
                %number of hours with detections
                if size(s_detections,2)==2
                    detStart = s_detections(:,1);
                    detEnd = s_detections(:,2);
                    
                    detStart = datevec(detStart);
                    detEnd = datevec(detEnd);
                    
                    hourStart = detStart(:,4);
                    hourEnd = detEnd(:,4);
                    
                    diffHour=hourEnd-hourStart+1;
                    
                    %correct for day shift
                    neg = find(diffHour < 0);
                    diffHour(neg) = diffHour(neg)+24;
                    
                    %minimze to hour
                    detStart(:,5)=0;
                    detStart(:,6)=0;
                    
                    hourNum=[];
                    
                    %find hours with detections
                    for a=1:length(diffHour)
                        hourAdd=[];
                        n=diffHour(a);
                        for i = 1:n;
                            hourNew = detStart(a,:);
                            hourNew(4) = hourNew(4) + (i-1);
                            hourAdd(i,:) = hourNew;
                        end
                        hourNum = [hourNum;hourAdd];
                    end
                    
                    hourNum = datenum(hourNum);
                    
                    %eliminate multiple of hours which have multiple detections
                    hourNum = unique(hourNum);
                    hourNum = datevec(hourNum);
                    
                    sumHours = size(hourNum,1);
                else
                    detStart = s_detections;
                    detStart = datevec(detStart);
                    detStart(:,5)=0;
                    detStart(:,6)=0;
                    detStart = datenum(detStart);
                    detStart = unique(detStart);
                    sumHours = length(detStart);
                end
                
                percDays = (sumDays/dayEffort)*100;
                percHours = (sumHours/hourEffort)*100;
                
                if isempty(c)
                    f = sprintf('%s%d%s-%s',project, deploy, site,s);
                    file = [f,'.txt'];
                else
                    f = sprintf('%s%d%s-%s-%s',project, deploy, site,s,c);
                    f = regexprep(f, '[/\\'']', '');
                    f = strrep(f, '?', '-QuestionMark');
                    file = [f,'.txt'];
                end
                
                
                fid = fopen(file,'wt');
                if isempty(c)
                    fprintf(fid, '%s %d %3.1f %d %3.1f %d %d\n', s,sumHours,percHours,...
                        sumDays,percDays,hourEffort,dayEffort);
                else
                    fprintf(fid, '%s %s %d %3.1f %d %3.1f %d %d\n', s,c,sumHours,percHours,...
                        sumDays,percDays,hourEffort,dayEffort);
                end
                fclose(fid);
                
                1;
            end  % end call type
        end
    end
end


1;




