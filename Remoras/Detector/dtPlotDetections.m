function dtPlotDetections(Times, Height, LineSpec)
% dtPlotDetections(Times, Height, LineSpec)
% Add detection marks to current plot
% Times is an N x 2 matrix where Times(N,:) denotes the start and end
% time of the Nth detection.
% Height indicates height at which the detection should be plotted 
%
% Do not modify the following line, maintained by CVS
% $Id: dtPlotDetections.m,v 1.2 2007/04/27 18:32:39 mroch Exp $
global HANDLES

% holding = ishold;
% % hold on;
% 1;
%%%%
fig = HANDLES.subplt.specgram;
hold(fig, 'on');

for idx = 1:size(Times,1)
  % Plot each detection specifying that the line cannot be selected by
  % a mouse click (prevents breakage of zoom functionality)
  plot(fig, Times(idx,:), [Height, Height], LineSpec, 'HitTest', 'off');
end

%%%%
hold(fig, 'off');

end
