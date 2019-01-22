function is_initGui(varargin)

global PARAMS REMORA
% check that database code is available
if ~exist('dbInit','file')
    error('ERROR: Please add database code to Matlab path or load Logger remora')
end
REMORA.image_set.color.bg1 = [1 1 1];  % white
REMORA.image_set.color.bg2 = [0.9 0.9 0]; % yellow
REMORA.image_set.color.bg3 = [.75 .875 1]; % light blue
REMORA.image_set.color.bg4 = [1.0 .60 .0]; % orange
REMORA.image_set.color.bg5 = [0.8 0.3 0.8]; % purple
REMORA.image_set.color.bg6 = [0.1 0.8 1.0]; % blue
REMORA.image_set.color.bg7 = [0.4 1.0 0.4]; % green
REMORA.image_set.color.bg8 = [0.8 0.8 0.8]; % gray

REMORA.image_set.sp_list = {'Kogia sp.';'UO Clicks';'Dolphin whistles';'Sperm whale';...
    'Boat';'Echosounder';'Noise';'Rain';'Data gap';...
    'Quiet'};

REMORA.image_set.query_words = {{'Kspp'};
    {'Gg','UO','Zc','Md','Me','UBW','Bb1'};
    {'UO'};
    {'Pm'};
    {'Anthro'};
    {'Anthro'};
    {'Other'}};

REMORA.image_set.query_call = {'Clicks';
    'Clicks';
    'Whistles';
    'Clicks';
    'Ship';
    'Active Sonar';
    'Masking'};

% Have user enter deployment info for query:
% Attempt to parse out the Project, Deployment, and Site from
% an open LTSA or XWav file to populate fields
if length(PARAMS.ltsa.infile) + length(PARAMS.infile) > 0
    ProjectSiteDeployRE = '(?<Project>[A-Za-z]+)(?<Deployment>\d+)(?<Site>[A-Za-z0-9]+)_.*';
    match = regexp(PARAMS.ltsa.infile, ProjectSiteDeployRE, 'names');
    if isempty(match)
        % Try the current input file
        match = regexp(PARAMS.infile, ProjectSiteDeployRE, 'names');
    end
    if isempty(match)
        Project = ''; Deployment = ''; Site = '';
        REMORA.image_set.DeploymentStart = '';
        REMORA.image_set.DeploymentEnd = '';
    else
        Project = match.Project;
        Deployment = str2double(match.Deployment);
        Site = match.Site;
        try
            info = dbDeploymentInfo(REMORA.image_set.query, 'Project', Project, ...
                'DeploymentID', Deployment, 'Site', Site);
            
            REMORA.image_set.DeploymentStart = ...
                dbISO8601toSerialDate(info.SamplingDetails.Channel(1).Start);
            REMORA.image_set.DeploymentEnd = ...
                dbISO8601toSerialDate(info.SamplingDetails.Channel(1).End);
        catch
            REMORA.image_set.DeploymentStart = '';
            REMORA.image_set.DeploymentEnd = '';
        end
    end
else
    % No LTSA or XWav open
    Project = '';
    Deployment = '';
    Site = '';
    REMORA.image_set.DeploymentStart = '';
    REMORA.image_set.DeploymentEnd = '';
end

% Text boxes have these attributes
REMORA.image_set.TextAttrib = {'Style', 'text', 'Units', 'normalized', ...
    'FontWeight', 'bold', 'HorizontalAlignment', 'center',...
    'BackgroundColor', REMORA.image_set.color.bg4};
% Edit boxes have these attributes
REMORA.image_set.EditAttrib = { ...
    'Style', 'edit', 'String', '', 'Units', 'normalized', ...
    'HorizontalAlignment', 'left', 'BackgroundColor', REMORA.image_set.color.bg1};

%%% Start figure to set metadata
REMORA.image_set.setMetadataGui=figure('CloseRequestFcn', @is_restorePointer,...
    'menubar', 'none',...
    'NumberTitle', 'off',...
    'name', 'Image Set',...
    'units', 'normalized',...
    'position', [0.025,0.05,0.3,0.4]);

%Project
textpos = [.2,.8, .3, .05];
REMORA.image_set.handles.project.text = uicontrol(REMORA.image_set.setMetadataGui,...
    'String', 'Project', 'position', textpos, REMORA.image_set.TextAttrib{:});
btnpos = [.5,.8, .3, .05];
REMORA.image_set.handles.project.disp = uicontrol(REMORA.image_set.setMetadataGui,...
    'position', btnpos, REMORA.image_set.EditAttrib{:}, 'String', Project);

% Deployment
textpos = [.2,.65, .3, .05];
REMORA.image_set.handles.deploy.text= uicontrol(REMORA.image_set.setMetadataGui,...
    'String', 'Deployment', 'Position', textpos, REMORA.image_set.TextAttrib{:});
btnpos = [.5,.65, .3, .05];
REMORA.image_set.handles.deploy.disp = uicontrol(REMORA.image_set.setMetadataGui,...
    'Position', btnpos, REMORA.image_set.EditAttrib{:}, 'String', num2str(Deployment));

% Site
textpos = [.2,.5, .3, .05];
REMORA.image_set.handles.site.text = uicontrol(REMORA.image_set.setMetadataGui,...
    'String', 'Site', 'Position', textpos,REMORA.image_set.TextAttrib{:});
btnpos = [.5,.5, .3, .05];
REMORA.image_set.handles.site.disp = uicontrol(REMORA.image_set.setMetadataGui,...
    'Position', btnpos, REMORA.image_set.EditAttrib{:}, 'String', Site);

% Save directory
textpos = [.2,.4, .3, .05];
REMORA.image_set.handles.savepath.text = uicontrol(REMORA.image_set.setMetadataGui,...
    'String', 'Output Folder', 'Position', textpos,REMORA.image_set.TextAttrib{:});
btnpos = [.5,.4, .3, .05];
REMORA.image_set.handles.savepath.disp = uicontrol(REMORA.image_set.setMetadataGui,...
    'Position', btnpos, REMORA.image_set.EditAttrib{:}, 'String', pwd);


% Make big button to press to confirm inputs
labelStr = 'Set Metadata';
btnpos = [.2,.9, .3, .1];
REMORA.image_set.handles.done = uicontrol(REMORA.image_set.setMetadataGui,...
    'style', 'pushbutton',...
    'string', labelStr,...
    'units', 'normalized',...
    'FontSize', 10,...
    'FontWeight','bold',...
    'position', btnpos, ...
    'HorizontalAlignment', 'left',...
    'BackgroundColor', REMORA.image_set.color.bg3,...
    'Callback', @is_setMetadata);

% setup checkboxes and other stuff but make invisible

half_list = round(length(REMORA.image_set.sp_list)/2);

for iBox = 1:length(REMORA.image_set.sp_list)
    in_window = [];
    if iBox>half_list
        horz_pos = .5;
        vert_pos = .8-((iBox-half_list)*.1);
    else
        horz_pos = .1;
        vert_pos = .8-(iBox*.1);
    end
    
    REMORA.image_set.handles.check_box(iBox,1) =...
        uicontrol(REMORA.image_set.setMetadataGui,'style','checkbox',...
        'string', REMORA.image_set.sp_list{iBox},...
        'Position',[horz_pos,vert_pos,.3,.08],...
        'Units','normalized','Visible','off');
end

% Make big button to press to save image
labelStr = 'Save Image';
btnpos = [.6, .1,.2, .1];
REMORA.image_set.handles.save_image = uicontrol(REMORA.image_set.setMetadataGui,...
    'style', 'pushbutton',...
    'string', labelStr,...
    'units', 'normalized',...
    'FontSize', 10,...
    'FontWeight','bold',...
    'position', btnpos, ...
    'HorizontalAlignment', 'left',...
    'BackgroundColor', [.75 .875 1],...
    'Callback', @is_saveImageToSet,...
    'Visible','off');

dbInitArgs = {};
REMORA.image_set.queries =[];

% Get detections for this LTSA        
if isempty(REMORA.image_set.queries)
    REMORA.image_set.queries = dbInit(dbInitArgs{:});
end

function is_setMetadata(varargin)
global REMORA PARAMS
y2k = datenum([2000,0,0,0,0,0]);
REMORA.image_set.project = get(REMORA.image_set.handles.project.disp,'String');
REMORA.image_set.site = get(REMORA.image_set.handles.site.disp,'String');
REMORA.image_set.deployment = get(REMORA.image_set.handles.deploy.disp,'String');
REMORA.image_set.start_time = PARAMS.ltsa.start.dnum + y2k;
REMORA.image_set.end_time = PARAMS.ltsa.end.dnum + y2k;
REMORA.image_set.savepath = get(REMORA.image_set.handles.savepath.disp,'String');

set(REMORA.image_set.handles.done, 'Visible', 'off')
set(REMORA.image_set.handles.project.text, 'Visible', 'off')
set(REMORA.image_set.handles.project.disp, 'Visible', 'off')
set(REMORA.image_set.handles.site.text, 'Visible', 'off')
set(REMORA.image_set.handles.site.disp, 'Visible', 'off')
set(REMORA.image_set.handles.deploy.text, 'Visible', 'off')
set(REMORA.image_set.handles.deploy.disp, 'Visible', 'off')
set(REMORA.image_set.handles.savepath.text, 'Visible', 'off')
set(REMORA.image_set.handles.savepath.disp, 'Visible', 'off')

set(REMORA.image_set.handles.save_image, 'Visible', 'on')
set(REMORA.image_set.handles.check_box, 'Visible', 'on')

is_runQuery


function is_restorePointer(varargin)
% restore_pointer
% During the initial phase of gathering information before
% we actually open the log, the user may abort by closing the
% new window.  Make sure that we are in a sane state when this
% happens

global REMORA

delete(REMORA.image_set.setMetadataGui);  % Remove logger gui
REMORA = rmfield(REMORA,'image_set');  % No longer valid


function is_saveImageToSet(varargin)
% Save image data to .mat file in specified output directory.
% NOTE: only values of LTSA are saved, no axes, not labels. This is aimed
% at quick loading for image processing applications.
% Filenames include original LTSA, start time of image segment, and labels
% of species identified in segment as numbers separated by '-'. These
% should be parsed out into one-hot encoding.

global HANDLES PARAMS REMORA
type_flags = find(cell2mat(get(REMORA.image_set.handles.check_box,...
    'Value')));
if ~isempty(intersect(type_flags,length(REMORA.image_set.handles.check_box)))...
        && (length(type_flags)>1)
    disp('ERROR: Can''t be quiet AND have another label!')
    disp('No figure saved.')
    return
end

ltsa_image = PARAMS.ltsa.pwr;% get(HANDLES.plt.ltsa,'CData');
filename_prefix = strrep(PARAMS.ltsa.infile,'.ltsa','');
filename_time = datestr((PARAMS.ltsa.plot.dnum)+...
    datenum(2000,0,0),'_yyyymmddTHHMMSS');

if ~isempty(type_flags)
    filename_suffix = [];
    for iFlag = 1:length(type_flags)
        filename_suffix = strcat(filename_suffix,...
            sprintf('-%d',type_flags(iFlag)));
    end
end
full_file_name = strcat(filename_prefix,filename_time,...
    filename_suffix,'.mat');
if ~isempty(REMORA.image_set.savepath)
    savepath = REMORA.image_set.savepath;
else
    savepath = pwd;
end
save(fullfile(savepath, full_file_name),...
    'ltsa_image','-mat')

fprintf('Image saved: %s\n', fullfile(savepath, full_file_name))
figure(HANDLES.fig.main)
