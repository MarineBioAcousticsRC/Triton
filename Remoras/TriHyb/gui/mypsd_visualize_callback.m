function mypsd_visualize_callback(~, ~)
global REMORA

ncPath = get(REMORA.mypsdViz.gui.ncPath, 'String');
figPath = get(REMORA.mypsdViz.gui.figOutputPath, 'String');

selectedBtn = get(REMORA.mypsdViz.gui.binGroup, 'SelectedObject');
binMode = get(selectedBtn, 'Tag');   % 'hourly' | 'daily' | 'oneminute'

disp('-------------------- Visualize HMD Input Parameters --------------------')
disp(['.nc Path: ', ncPath])
disp(['Figure Output Path: ', figPath])
disp(['Bin by: ', binMode])

sm_visualize_HMD(ncPath, figPath, binMode);

end
