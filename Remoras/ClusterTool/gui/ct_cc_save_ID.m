function ct_cc_save_ID(hObject,eventdata)
% save an ID file for detEdit
% note that if you do this, it will not label everything, just what has
% made it into clusters. This might confuse people...

global REMORA


% prompt to label 
ct_cc_apply_labels_gui
waitfor(REMORA.fig.ct.cc_applylabels)

ct_cc_saveID_gui
waitfor(REMORA.fig.ct.cc_saveID)



% disp('Saving ID files to %s...', REMORA.ct.CC.id.outputFolder)

% ct_save_clusters_to_ID
% disp('ID files complete')
% show some message about saving in progress