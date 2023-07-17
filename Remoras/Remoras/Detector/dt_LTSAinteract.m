global HANDLES PARAMS

% 33 rows, 4 columns, except for motion control buttons
r = 36; % rows
c = 4;  % columns
h = 1/r;
w = 1/c;
%
% make x and y locations in plot control window (relative units)
for ci = 1:c
    x(:,ci) = ((ci-1)/c) .* ones(r,1);
    y(:,ci) = h .* [r-1:-1:0]';
end
%
% offset y to provide space between control sections

dy = h * 0.25;
ri = 1;
y(ri,:) = y(ri,:) - dy;
%
% rows 2-3,4-5,6-7,8-9,
for ri = 2:5
    y(2*ri-2,:) = y(2*ri-2,:) - ri * dy;
    y(2*ri-1,:) = y(2*ri-1,:) - ri * dy;
end
% rows 10-15
for ri = 5:10
    y(ri+5,:) = y(ri+5,:) - (ri+1) * dy;
end

% rows 16-17, 18-19, 20-21, 22-23, 24-25, 26-27
shift = 2 * h;
for ri = 8:14               %Sean - do you intend for this indexing to start at y(14)? mss  (14+15 don't get used, so it doesn't affect anything - just unneccessary calculations)
   y(2*ri-2,:) = y(2*ri-2,:) - (ri+1)*dy + shift;
   y(2*ri-1,:) = y(2*ri-1,:) - (ri+1)*dy + shift;
end
% row 28-40
for ri = 14: r-14
    y(ri+14,:) = y(ri+14,:) - (ri+2) * dy + shift;
end

bgColor2 = [.75 1 .875]; % light green for LTSA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Detection controls
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%***********************************
if isfield(PARAMS.ltsa, 'dt') && ~ isfield(PARAMS.ltsa.dt, 'Enabled')
    % set default detection if not already done
    PARAMS.ltsa.dt.Enabled = get(HANDLES.ltsa.dt.Enabled, 'Value');
end
%***********************************
% Enable/disable detection
%***********************************
labelStr = 'Detector';
btnPos = [x(4,4) y(4,4) w h];
HANDLES.ltsa.dt.Enabled = uicontrol(HANDLES.fig.ctrl, ...
    'Style','radiobutton', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'BackgroundColor',bgColor2,...
    'String',labelStr, ...
    'FontUnits','normalized', ...
    'Visible','on',...
    'Value', PARAMS.ltsa.dt.ifPlot, ...
    'Callback','control_ltsa(''detection_toggle'')'); 
%***********************************
% Enable/disable noise selection
%***********************************
labelStr = 'Pick noise';
btnPos = [x(5,4) y(5,4) w h];
HANDLES.ltsa.dt.NoiseEst = uicontrol(HANDLES.fig.ctrl, ...
    'Style','radiobutton', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'BackgroundColor',bgColor2,...
    'String',labelStr, ...
    'FontUnits','normalized', ...
    'Visible','on',...
    'Enable', 'on',   ...             
    'Value', 0,...
    'Callback','control_ltsa(''detection_noise'')'); 

%***********************************
% Detection controls group
%***********************************
HANDLES.ltsa.dt.controls = [ ...
    HANDLES.ltsa.dt.Enabled HANDLES.ltsa.dt.NoiseEst];