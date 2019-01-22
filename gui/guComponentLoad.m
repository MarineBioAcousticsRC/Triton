function handles = guComponentLoad(hObject, eventdata, handles, component, ...
                                   varargin)
% handles = guComponentLoad(hObject, eventdata, handles, ...
%     component, ComponentSpecificArgs)
%
% Add a guide created figure to the figure contained in hObject.
% This is useful for building an interface out of reusable components,
% each represented as a single GUIDE figure.  All reusable components
% should be created in the top-left of their respective figures.  As
% each component is added with guComponentLoad (one call at a time)
% additional components will be stacked vertically underneath existing
% components.
%
% In some cases, this may create an interface that is not entirely
% visible as the vertical components exceed the normalized unit y 
% invertval of [0, 1].  The returned handles structure will always have
% a MinimumY value.  After all components have been loaded, if MinimumY
% is < 0, the figure's normalized space (0,0)-(1,1) was not large enough
% to display all loaded components.  A call to guComponentResize will 
% rescale the components such that all components are within the visible
% space.
%
% How to create components:
%
% 1.  Guide - Create a guide figure.  Components must be placed at the top
%       of figure.  Failure to do so will result in vertical gaps in the
%       components.  It is assumed that no handle graphics object has
%       negative height.  Callbacks works as normal with a couple of notable
%       exceptions:
%       
%       1.  The handles structure is not populated in the same manner.
%           A tagged component named button1 would normally be 
%           handles.OKbutton.  When loaded via guComponentLoad, each
%           components tags are grouped into a structure with the name
%           of the component.  So, if button1 was in a GUIDE structure
%           FooBarChooser (FooBarChooser.fig and FooBarChooser.m), the
%           handle would be handles.FooBarChooser.OKbutton.  
%       2.  Intitialization is slightly different...
%
% 2.  Create an empty figure and save its handle.
% 3.  Add the components.
% 4.  Call guComponentScale which checks if the figure needs to be scaled
%       so that all components are visible and makes the change if
%       necessary.  Note that guComponentScale should only be called
%       after all components have been loaded.  Calling it multiple times
%       could result in some componenents being shrunk more than once,
%       leading to components of differing scales.
%
% Example:
%       fig_h = figure('Name', 'Demo');         % open empty figure
%       % Load in desired components.  Note that we use [] for handles
%       % on the first call.
%       handles = guComponentLoad(fig_h, [], [], 'FooBarChooser');
%       handles = guComponentLoad(fig_h, [], handles, 'ConfirmCancel');
%       handles = guComponentResize(fig_h, [], handles);

[dummy, name] = fileparts(component);

% Open the Matlab figure and load interface into a figure.
tmp_h = openfig(sprintf('%s.fig', name), 'new', 'invisible');

% Top level components that are already present.
existing_h = get(tmp_h, 'Children');


% New components to add
% We assume that panels are laid out vertically, never horizontally
new_h = get(tmp_h, 'Children');

% GUI components have an ordered tuple Extent.  
% Assign symbolic names to tuple elements that we will need.
PosY = 2;
PosValues = 4;

% Load positions for new componenents.  Also store units so we can reset
% them later.
Units = cell(length(new_h), 1);
Positions = zeros(length(new_h), PosValues);
for idx=1:length(new_h)
  Units{idx} = get(new_h(idx), 'Units');
  if ~ strcmp(Units{idx}, 'normalized')
    set(new_h(idx), 'Units', 'normalized');
  end
  Positions(idx,:) = get(existing_h(idx), 'Position');
end

% Translate all components down  by the lowest component in the existing
% figure (if one exists)
if isfield(handles, 'MinimumY')
  Positions(:, PosY) = Positions(:, PosY) - (1.0 - handles.MinimumY);
  for idx=1:length(new_h)
    set(new_h(idx), 'Position', Positions(idx,:));
  end
end
handles.MinimumY = min(Positions(:,PosY));


for idx=1:length(new_h)
  % Move to requesting object
  set(new_h(idx), 'Parent', hObject);
  % Find all subjects of this object (including itself) that have Tag
  % values and add them to the tags structure.  We assume that these
  % tags are all unique.
  taggedchildren = findobj(new_h(idx), '-regexp', 'Tag', '[^'']');
  if ~ isempty(taggedchildren)
    tags = get(taggedchildren, 'Tag');
    if isstr(tags)
        tags = {tags};   % Single tag, expecting cell array, convert
    end
    for tidx = 1:length(taggedchildren)
      handles.(name).(tags{tidx}) = taggedchildren(tidx);
    end
  end
end

handles = feval(name, sprintf('%s_OpeningFcn', name), hObject, eventdata, ...
                handles, varargin{:});

delete(tmp_h); % figure no longer needed
