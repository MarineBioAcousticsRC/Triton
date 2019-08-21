function ct_cc_save_plots

global REMORA

if ~isfield(REMORA.ct.CC,'output')
    warning('No composite clusters loaded')
    ct_load_composite_clusters
end

if isfield(REMORA.fig, 'ct')
    % check if the figure already exists. If so, don't move it.
    if isfield(REMORA.fig.ct, 'cc_savefigs') && isvalid(REMORA.fig.ct.cc_savefigs)
        defaultPos = get(REMORA.fig.ct.cc_savefigs,'Position');
    else
        initAxes = 1;
    end
else 
    initAxes = 1;
end

if initAxes
    REMORA.fig.ct.cc_savefigs = figure;
    
    set(REMORA.fig.ct.cc_savefigs,...
        'Units','normalized',...
        'ToolBar', 'none',...
        'MenuBar','none',...
        'NumberTitle','off','Name',...
        'Composite Clustering Tool - v1.0',...
        'Visible','on');    %
end

clf

% outdir

% all cluster plots checkbox

% per cluster plots checkbox


% put a "Save" button
labelStr = 'Save';
btnPos=[.4, 0, .2, (1/nRows)*.4];

REMORA.ct.CC.apply_labels.doneBtn = uicontrol(REMORA.fig.ct.cc_applylabels,...
    'Style','pushbutton',...
    'Units','normalized',...
    'Position',btnPos,...
    'BackgroundColor','green',...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'FontSize',.5,...
    'Visible','on',...
    'FontWeight','bold',...
    'Callback','ct_cc_exportID_gui');

% bring to top
figure(REMORA.fig.ct.cc_applylabels)

end
