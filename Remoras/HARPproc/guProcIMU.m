function guProcIMU()
% simple GUI for processing & plotting IMU files
%
% 260220 BJT

%% get screen size
set(0,'units','pixels') ;
screen_pix = get(0,'screensize');

% make coordinates
% mostly works but seems slightly off...seems like ncols isn't working
% as expected.  Seems like there's extra space on the right side of the figure

fPos = [ 0.1, 0.1 ]; % normalized position of main window
fsz = [ 0.6, 0.8 ]; % normalized size of main window

% convert to pixels
fPos = [ fPos(1)*screen_pix(3), fPos(2)*screen_pix(4) ];
fsz = [ fsz(1)*screen_pix(3), fsz(2)*screen_pix(4) ];


% these are for ui elements, position relative to container
% units must be pixels for at least some?
nrow = 20;
ncol = 40;
x = round(linspace( 0, fsz(1)-fPos(1), ncol )); % [pixels]
y = round(linspace( 0, fsz(2)-fPos(2), nrow )); % [pixels]
xlen = x(2)-x(1); % size of each x tick ( approx )
ylen = y(2)-y(1); % size of each y tick ( approx )

fTag = 'guProcIMU';

% look for existing uiFigure
fig1 = findall(groot,'Type','figure','Tag',fTag);
if isempty(fig1) || ~isvalid(fig1)
    fig1 = uifigure('Name','Search/Select Folders w/ *.imu files','Tag',fTag);
    fig1.Units = 'pixels';
    fig1.Position = [ fPos(1), fPos(2), fsz(1),fsz(2) ];
    % Root folder selection
    btnRoot = uibutton(fig1,'Text','Select Root Folder',...
        'Position',[ x(2), y(end), 5*xlen, 1*ylen ],...
        'ButtonPushedFcn',@(btn,event)selectRoot());

    lblRoot = uilabel(fig1,'Text','No folder selected',...
        'Position',[ x(8) ,y(end), 10*xlen, 1*ylen ] );

    % Pattern input
    lblPattern = uilabel(fig1,'Text','File name ( wildcards allowed ):',...
        'Position',[x(2), y(end-2), 8*xlen, 1*ylen]);

    txtPattern = uieditfield(fig1,'text',...
        'Position',[x(10), y(end-2),20*xlen, 1*ylen ],...
        'Value','*.imu');

    % Search button
    btnSearch = uibutton(fig1,'Text','Search',...
        'Position',[ x(2), y(end-4), 6*xlen, 1*ylen],...
        'ButtonPushedFcn',@(btn,event)searchFolders());

    % Folder list
    lstFolders = uilistbox(fig1,...
        'Position',[x(2) y(2) (ncol)*xlen (nrow-7)*ylen ],...
        'Items',{''},...
        'Multiselect','on');

    % button run IMU->Euler code
    btnRun1 = uibutton(fig1,'Text','Process IMU->Euler',...
        'Position',[ x(end-4), y(end-2), 6*xlen, 1*ylen],...
        'ButtonPushedFcn',@(btn,event)runIMU_to_euler());

    % button run plot_AGM_YPR()
    % this should ONLY run on disk length IMU files
    btnRun2 = uibutton(fig1,'Text','Plot processed IMU Data',...
        'Position',[ x(end-4), y(end-4), 6*xlen, 1*ylen],...
        'ButtonPushedFcn',@(btn,event)plot_AGM_YPR());
else
    figure(fig1);  % bring to front
end



% Store root path
rootPath = '';

%% callbacks!

    function selectRoot()
        folder = uigetdir;
        if folder ~= 0
            rootPath = folder;
            lblRoot.Text = rootPath;
        end
    end

    function runIMU_to_euler()
        dirlist = lstFolders.Value;
        if isempty(dirlist)
            uialert(fig1,'Select folders from list','Error');
            return;
        end

        ndir = length(dirlist);
        fprintf('Processing IMU files in %d directories\n\n',ndir);
        for d = 1:ndir
            cdir = dirlist{d};
            imufiles = dir(fullfile(cdir,'**','*.imu'));
            iffns = fullfile({imufiles.folder}, {imufiles.name});
            fprintf('(%d/%d) : %d imu files \n', d, ndir, length(iffns));
            fprintf('\t%s\n', cdir);
            IMU_to_euler_260304(iffns);
        end

        1;
    end

    function plot_AGM_YPR()
        dirlist = lstFolders.Value;
        if isempty(dirlist)
            uialert(fig1,'Select folders from list','Error');
            return;
        end

        ndir = length(dirlist);
        fprintf('Plotting IMU files in %d directories\n\n',ndir);
        for d = 1:ndir
            cdir = dirlist{d};
            % only process disk length mat files
            imatfiles = dir(fullfile(cdir,'**','*disk*_procIMU*.mat'));
            iffns = fullfile({imatfiles.folder}, {imatfiles.name});
            fprintf('(%d/%d) : %d processed imu files \n', d, ndir, length(iffns));
            fprintf('\t%s\n', cdir);
            plot_AGM_YPR_260220(iffns);
        end
        fprintf('Done!\n');
        1;
    end


    function searchFolders()
        if isempty(rootPath)
            uialert(fig1,'Please select a root folder first.','Error');
            return;
        end

        pattern = txtPattern.Value;

        %         % Recursively list all files
        files = dir(fullfile(rootPath, '**',pattern));

        % we only want unique list of directories
        dirs = unique({ files.folder }');


        matchedFolders = dirs;

        if isempty(matchedFolders)
            lstFolders.Items = {'No matches found'};
        else
            lstFolders.Items = matchedFolders;
        end
    end

end