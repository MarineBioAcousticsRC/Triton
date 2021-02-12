function ct_cc_apply_labels_gui(varargin)

global REMORA

initAxes = 0;

if ~isfield(REMORA.ct.CC,'output')
    warning('No composite clusters loaded')
    ct_load_composite_clusters
end
if isfield(REMORA.fig, 'ct')
    % check if the figure already exists. If so, don't move it.
    if isfield(REMORA.fig.ct, 'cc_applylabels') && isvalid(REMORA.fig.ct.cc_applylabels)
        defaultPos = get(REMORA.fig.ct.cc_applylabels,'Position');
    else
        initAxes = 1;
    end
else 
    initAxes = 1;
end

if initAxes
    REMORA.fig.ct.cc_applylabels = figure;
    
    set(REMORA.fig.ct.cc_applylabels,...
        'Units','normalized',...
        'ToolBar', 'none',...
        'MenuBar','none',...
        'NumberTitle','off','Name',...
        'Composite Clustering Tool - v1.0: Apply Labels',...
        'Visible','on');    %
end

clf
currentH = REMORA.fig.ct.cc_applylabels;
t1 = uicontrol(currentH,'Style','text',...
    'String','Optional: Edit cluster labels',...
    'Units','normalized',...
    'Position',[0.1,.85,.8,.15],...
    'HandleVisibility','on',...
    'Visible','on',...
    'FontSize',11);

nClust = length(REMORA.ct.CC.output.nodeSet);
nRows = 3; % number of rows of subplots, one subplot per type
nCols = ceil(nClust/nRows); % number of columns of subplots
% make vectors to compute field locations from
rowVec = (.9-(reshape(repmat(1:nRows,nCols,1),nCols*nRows,1)-1)./nRows)*.65;
colVec  = (repmat([1:nCols]',nRows,1)-1)./nCols;

fW = min(.05*nCols,.9);
fH = min(.05*nRows,.9);

default_pos = [1-fW-.05,0.05,fW,fH];
set(REMORA.fig.ct.cc_applylabels,'Position',default_pos)

if ~isfield(REMORA.ct.CC.output,'labelStr')
    % if no labels are available, make defaults
    labelStr = {};
    for iEd = 1:nClust
        % Make editable name field
        labelStr{iEd} = sprintf('Cluster%0.0f',iEd);
    end
    REMORA.ct.CC.output.labelStr = labelStr;
end
REMORA.ct.CC.apply_labels = {};
for iEd = 1:nClust
    % Make editable name field
    btnPos=[colVec(iEd)+.01, rowVec(iEd), (1/nCols)*.8,(1/nRows)*.5];
    REMORA.ct.CC.apply_labels.labels{iEd} = uicontrol(REMORA.fig.ct.cc_applylabels,...
    'Style','edit',...
    'Units','normalized',...
    'Position',btnPos,...
    'BackgroundColor','white',...
    'String',REMORA.ct.CC.output.labelStr{iEd},...
    'FontUnits','normalized', ...
    'HorizontalAlignment','left',...
    'Visible','on',...
    'Callback',{@ct_cc_set_labels,iEd});
end

% put a "done" button
labelStr = 'Done';
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
    'Callback',@ct_cc_close_label_gui);

% bring to top
figure(REMORA.fig.ct.cc_applylabels)

end

function ct_cc_set_labels(hObject,eventdata,editIdx)
global REMORA
newLabel = get(REMORA.ct.CC.apply_labels.labels{editIdx},'String');
REMORA.ct.CC.output.labelStr{editIdx} = newLabel;

end

function ct_cc_close_label_gui(hObject,eventdata)
global REMORA
close(REMORA.fig.ct.cc_applylabels)
end
