function ct_cc_remove_simBins(varargin)

global REMORA

initAxes = 0;

if ~isfield(REMORA.ct.CC,'output')
    warning('No composite clusters loaded')
    ct_load_composite_clusters
end

REMORA.fig.ct.cc_rmsimbins = figure;

set(REMORA.fig.ct.cc_rmsimbins,...
    'Units','normalized',...
    'ToolBar', 'none',...
    'MenuBar','none',...
    'NumberTitle','off','Name',...
    'Composite Clustering Tool - v1.0: Exclude Bins Similar to Types',...
    'Visible','on');    %


clf
currentH = REMORA.fig.ct.cc_rmsimbins;
t1 = uicontrol(currentH,'Style','text',...
    'String','Check boxes of undesired clusters',...
    'Units','normalized',...
    'Position',[0.1,.8,.8,.15],...
    'HandleVisibility','on',...
    'Visible','on',...
    'FontSize',11);

nClust = length(REMORA.ct.CC.output.nodeSet);
nRows = 3; % number of rows of subplots, one subplot per type
nCols = ceil(nClust/nRows); % number of columns of subplots
% make vectors to compute field locations from
rowVec = (.9-(reshape(repmat(1:nRows,nCols,1),nCols*nRows,1)-1)./nRows)*.65;
colVec  = (repmat([1:nCols]',nRows,1)-1)./nCols;

fW = min(.07*nCols,.9);
fH = min(.07*nRows,.9);

default_pos = [1-fW-.05,0.05,fW,fH];
set(REMORA.fig.ct.cc_rmsimbins,'Position',default_pos)
REMORA.ct.CC.output.removeTF_simbins = zeros(nClust,1);
labelStr = {};
for iEd = 1:nClust
    % Make editable name field
    labelStr{iEd} = sprintf('Cluster %0.0f',iEd);
end

REMORA.ct.CC.rm_simbins = {};
for iEd = 1:nClust
    % Make editable name field
    btnPos=[colVec(iEd)+.01, rowVec(iEd), (1/nCols)*.8,(1/nRows)*.5];
    REMORA.ct.CC.rm_simbins.labels{iEd} = uicontrol(REMORA.fig.ct.cc_rmsimbins,...
        'Style','checkbox',...
        'Units','normalized',...
        'Position',btnPos,...
        'BackgroundColor','white',...
        'ForegroundColor','k',...
        'String',labelStr{iEd},...
        'Value',REMORA.ct.CC.output.removeTF_simbins(iEd),...
        'FontUnits','normalized', ...
        'HorizontalAlignment','left',...
        'Visible','on',...
        'Callback',{@ct_cc_check_excluded_sb,iEd});
end

% put a "done" button
labelStr = 'Done';
btnPos=[.4, 0, .2, (1/nRows)*.4];

REMORA.ct.CC.rm_simbins.doneBtn = uicontrol(REMORA.fig.ct.cc_rmsimbins,...
    'Style','pushbutton',...
    'Units','normalized',...
    'Position',btnPos,...
    'BackgroundColor','green',...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'FontSize',.5,...
    'Visible','on',...
    'FontWeight','bold',...
    'Callback',@ct_cc_close_rm_cluster_gui_sb);

% bring to top
figure(REMORA.fig.ct.cc_rmsimbins)

end

function ct_cc_check_excluded_sb(hObject,eventdata,editIdx)
global REMORA
removeTF_simbins = get(REMORA.ct.CC.rm_simbins.labels{editIdx},'Value');
REMORA.ct.CC.output.removeTF_simbins(editIdx) = removeTF_simbins;

end

function ct_cc_close_rm_cluster_gui_sb(hObject,eventdata)
global REMORA
removeSet = find(REMORA.ct.CC.output.removeTF_simbins);
% store bin times somewhere
REMORA.ct.CC.sbSet = [cell2mat([REMORA.ct.CC.output.Tfinal(removeSet,1)])];
close(REMORA.fig.ct.cc_rmsimbins)
close(REMORA.fig.ct.cc_postcluster)
% if isfield(REMORA.fig.ct,'status')
%     close(REMORA.fig.ct.status)
% end
% enable option on composite window and show it.
if ~isempty(REMORA.ct.CC.sbSet)
    if isfield(REMORA.ct,'CC_verify')
        set(REMORA.ct.CC_verify.rmSimBinCheck,'Enable','on','Value',1)
        REMORA.ct.CC_params.rmSimBins = 1;
        
        showSBParams = 'on';
        
        set(REMORA.ct.CC_verify.SBdiffTxt,'Visible',showSBParams)
        set(REMORA.ct.CC_verify.SBdiffEdTxt,'Visible',showSBParams)
        set(REMORA.ct.CC_verify.SBpercTxt,'Visible',showSBParams)
        set(REMORA.ct.CC_verify.SBpercEdTxt,'Visible',showSBParams)
        
        figure(REMORA.fig.ct.CC_settings)
    else
        ct_init_compClust_window
        set(REMORA.ct.CC_verify.rmSimBinCheck,'Enable','on','Value',1)
        REMORA.ct.CC_params.rmSimBins = 1;
        
        showSBParams = 'on';
        
        set(REMORA.ct.CC_verify.SBdiffTxt,'Visible',showSBParams)
        set(REMORA.ct.CC_verify.SBdiffEdTxt,'Visible',showSBParams)
        set(REMORA.ct.CC_verify.SBpercTxt,'Visible',showSBParams)
        set(REMORA.ct.CC_verify.SBpercEdTxt,'Visible',showSBParams)
    end
end


end
