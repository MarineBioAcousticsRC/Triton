function is_labelImages(varargin)

global REMORA PARAMS HANDLES

for iBox = 1:length(REMORA.image_set.sp_list)
    
    window_start = PARAMS.ltsa.plot.dnum+datenum([2000,0,0]);
    window_end = window_start+datenum([0,0,0,PARAMS.ltsa.t(end),0,0]);
    % create list of checkboxes and species
    spPresent = zeros(size(REMORA.image_set.sp_list));
    
    % check boxes for which there are detections in the time window.
    this_sp_times =  REMORA.image_set.timestamps{iBox};
    if ~isempty(this_sp_times)
        starts_in_window = find(this_sp_times(:,1)>=window_start &...
            this_sp_times(:,1)<=window_end);
        if size(this_sp_times,2)>1
            ends_in_window = find(this_sp_times(:,2)>=window_start &...
                this_sp_times(:,1)<=window_end);
        else
            ends_in_window = [];
        end
        in_window = unique([starts_in_window;ends_in_window]);
        
        if ~isempty(in_window)
            spPresent(iBox,1)=1;
        end
    end
    % go through and set checkboxes based on latest query
    for iTF = 1:length(spPresent)
        set(REMORA.image_set.handles.check_box(iBox,1),'Value',...
            spPresent(iBox))
    end
    
end
figure(REMORA.image_set.setMetadataGui)
figure(HANDLES.fig.main)

