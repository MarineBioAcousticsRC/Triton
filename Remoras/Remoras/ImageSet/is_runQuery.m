function is_runQuery(varargin)

global REMORA


this_project = REMORA.image_set.project;
site = REMORA.image_set.site;
deployment = REMORA.image_set.deployment;
start_time = REMORA.image_set.start_time;
end_time = REMORA.image_set.end_time;
start_string = datestr(start_time,'yyyy-mm-ddTHH:MM:SSZ');
end_string = datestr(end_time,'yyyy-mm-ddTHH:MM:SSZ');


dbSpeciesFmt('Input', 'Abbrev', 'SIO.SWAL.v1');
dbSpeciesFmt('Output', 'Vernacular', 'English');
disp('Querying Tethys for effort')
timestamps = cell(size(REMORA.image_set.sp_list));
for iSp1 = 1:length(REMORA.image_set.query_words)
    merged_timestamps = [];
    for iSp2 = 1:length(REMORA.image_set.query_words{iSp1})
        % Get effort for the project, deployment, and site
        [detections, endP] = dbGetDetections(REMORA.image_set.queries,...
            'Project',this_project,...
            'Deployment', deployment, 'Site',site,'SpeciesID',...
        	REMORA.image_set.query_words{iSp1}{iSp2}, 'Call',...
            REMORA.image_set.query_call{iSp1});
        merged_timestamps = [merged_timestamps;detections];
    end
    timestamps{iSp1,1} = merged_timestamps;
    if isempty(merged_timestamps)
        fprintf('Tethys returned 0 detections for %s\n',...
            REMORA.image_set.sp_list{iSp1});
    else
        fprintf('Tethys returned %d detections for %s\n',...
            size(merged_timestamps,1),REMORA.image_set.sp_list{iSp1});
    end
end
disp('Done querying Tethys for effort')
REMORA.image_set.timestamps = timestamps;

is_labelImages