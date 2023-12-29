function [timestamps, EndP, info] = dbDomDetParse(dom,return_elements)

event_duration = 0;
% Assume only start times until we know better
EndP = [];

% Retrieve detection records from document model
if isempty(dom)
    timestamps = [];
    deploymentIdx = [];
    deployments = [];
else
    [timestamps, missingP] = dbParseDates(dom);
    EndCount = sum( ~missingP(:,end));
    
    if EndCount == 0
        % No end times were detected
        if event_duration == 0
            timestamps(:, 2) = [];  % No duration, remove end time
        else
            % Set interval to specified duration
            % Note that there is no guarantee that this will not create
            % overlapping events.
            timestamps(:, 2) = timestamps(:, 1) + event_duration;
        end
    end
    
    if nargout > 2
        indices = dom.item(0).getElementsByTagName('idx');
        indicesN = indices.getLength();
        info.deploymentIdx = zeros(indicesN, 1);
        for idx=1:indicesN
            info.deploymentIdx(idx) = str2double(indices.item(idx-1).getFirstChild().getNodeValue());
        end
        depdom = dbXPathDomQuery(dom, 'ty:Result/Sources');
        deploymentsN = depdom.item(0).getLength();
        info.deployments = struct('EnsembleName', cell(deploymentsN,1), 'Project', cell(deploymentsN,1), 'Deployment', cell(deploymentsN,1), 'Site', cell(deploymentsN,1), 'Cruise', cell(deploymentsN,1));
        for idx = 1:deploymentsN
            item = depdom.item(0).item(idx-1);
            for childidx = 1:item.getLength()
                child = item.item(childidx-1);
                field = char(child.getNodeName());
                if strcmp(field, '#text')  % we don't care about extraneous text
                    continue
                end
                value = char(child.getFirstChild().getNodeValue());
                dvalue = str2double(value);
                if ~ isnan(dvalue)
                    value = dvalue;
                end
                info.deployments(idx).(field) = value;
            end
        end
        
        N = size(timestamps, 1);
        warnings = {};
        if ~isempty(return_elements)
            % Pull out detections, should have N entries
            detdom = dbXPathDomQuery(dom, 'ty:Result/Detections/Detection');
            assert(detdom.getLength() == N, 'Number of detections and detection info do not match')
            
            % Map return elements to the field names that will be returned.
            fieldnm = regexprep(return_elements, '.*/([^/]+$)', '$1');
            for idx = 1:length(fieldnm)
                info.(fieldnm{idx}) = cell(N, 1);
            end
            % Populate
            for idx = 1:N
                entrydom = detdom.item(idx-1);
                for fidx = 1:length(fieldnm)
                    itemdom = dbXPathDomQuery(entrydom, fieldnm{fidx});
                    if itemdom.getLength() > 0
                        item0 = itemdom.item(0);
                        info.(fieldnm{fidx}){idx} = ...
                            char(item0.getFirstChild().getNodeValue());
                    end
                end
            end
        end
    end
    
    
end