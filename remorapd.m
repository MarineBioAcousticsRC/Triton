function miscpd(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% remorapd.m
%
% the callback for all the remora pull down actions.
%
% Parameters:
%         action - a string that is the action to be preformed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES DATA REMORA


% set variables used by multiple cases
% RemoraConfFile = fullfile(fileparts(which('triton')), 'Settings',...
%     'InstalledRemoras.cnf');
% TritonRemoraDir = fullfile(fileparts(which('triton')), 'Remora');
RemoraConfFile = fullfile(PARAMS.path.Settings,'InstalledRemoras.cnf');

switch action

    case'add_remora'
        %prompt for remora location
        remPath = uigetdir('', 'Select the folder that contains your remora');
        if remPath == 0
            return; %user clicked cancel
        end
        [path, folderName] = fileparts(remPath);
        original_rem = fullfile(path, folderName);
        %Creates a varible that holds the new Remora path
%         remoraDir = fullfile(fileparts(which('triton')), 'Remora', folderName);
        remoraDir = fullfile(PARAMS.path.Remoras, folderName);
        %check if that file name already exists
        %add to the RemoraConfFile file, use check_path.m as reference
        %for how to write in a file with fopen/fprintf
        if isequal(original_rem, remoraDir)
            disp_msg('Remora appears to be in remora dir, not copying any files...');
        else
            copyfile(original_rem, remoraDir);
        end
        %RemoraConfFile exists, write to it
%         tritonDir = fileparts(which('triton'));
        cd(PARAMS.path.Triton);
        triton_path = pwd;
        dirs = dir('Remora');
        % is the remora already in our conf file?
        cnf_txt = fileread(RemoraConfFile);
        sidx = strfind(cnf_txt,remoraDir); % starting idx of remoraDir in cnf_txt
        if ~isempty(sidx)
            disp_msg(sprintf('Remora: %s already in conf file', remoraDir));
            restart_triton_dlg();
            return
        end
        fid = fopen(RemoraConfFile, 'a+');
        fprintf(fid,'%s\n',remoraDir);
        fclose(fid);
        
        %     if strcmp(remoraDir, remPath)
        %       warndlg(['The remora is already in the remora directory, restart triton to ' ...
        %         'add the functionality to triton']);
        %       return
        %     end
        %copies path to a newly created directory. Directory has the same name as
        %the folder it came from. Also if no Remora folder is present i.e. none
        %have been added, it creates that folder as well.
        % BJT 12/18/2013 what was the intention of the following 3 lines?
        %     copyfile(remPath, remoraDir, 'f');
        %     addpath(remoraDir);
        %     savepath;
        restart_triton_dlg();
        % Removes remoras
    case 'rem_remora'
        dir1 = cd;
%         cd(TritonRemoraDir);
%         removedRemDir = uigetdir(TritonRemoraDir, ...
        cd(PARAMS.path.Remoras);
        removedRemDir = uigetdir(PARAMS.path.Remoras, ...
            'Which do you like to remove?');
        
        if removedRemDir == 0
            cd(dir1);
            return;%user clicked cancel return
        end
        
        button = questdlg('Do you want to remove this remora or back it up?',...
            'Remove','Backup','Cancel',...
            'Remove', 'Backup');
        
        if strcmp(button, 'Remove')
            rmpath(genpath(removedRemDir));
            [ status, message, messageid ] = rmdir(removedRemDir,'s');
            if status ~= 1
                disp_msg(message) 
            end
            %read in cnf file contents, match remora to be removed, write to new
            %file
            fid = fopen(RemoraConfFile,'r');
            remlist = textscan(fid,'%s','delimiter','\n');
            remlist = remlist{1,1}; % simplifies indexing
            fclose(fid);
            if isempty(remlist)
                disp_msg('No remoras to remove!')
                return
            end
            % clobber the existing cnf
            fod = fopen(RemoraConfFile,'w');
            for rem=1:size(remlist,1)
                if strcmp(char(remlist{rem,1}),removedRemDir)
                    [ ~, RemoraName ] = fileparts(removedRemDir);
                    disp_msg(sprintf('Removing remora from cnf file: %s', RemoraName));
                else
                    warndlg('Remora already deleted from .cnf file');
                    fprintf(fod,'%s\n',char(remlist{rem,1}));
                end
            end
            fclose(fod);
            savepath;
            restart_triton_dlg();
        elseif strcmp(button, 'Backup')
            backUp = uigetdir('', 'Where do you want the backup?');
            if backUp ~= 0
                [path, name] = fileparts(removedRemDir);
                % don't hardcode in path conventions!!!!!
                %[success, errMessage, ignore] = movefile([removedRem '\*'], [backUp '\' name], 'f');
                [success, errMessage, ~] = copyfile(fullfile(removedRemDir,'*'), ...
                    fullfile(backUp,name),'f');
                if success ~= 0
                    rmdir(removedRemDir,'s');
                    rmpath(removedRemDir);
                else
                    disp_msg(sprintf('Couldn''t backup because %s', ...
                        errMessage));
                end
            elseif backUp == 0
                cd(dir1);
                return;%user clicked cancel return
            end
            %read in cnf file contents, match remora to be removed, write to new
            %file
            fid = fopen(RemoraConfFile,'r');
            remlist = textscan(fid,'%s','delimiter','\n');
            remlist = remlist{1,1}; % simplifies indexing
            fclose(fid);
            if isempty(remlist)
                disp_msg('No remoras to remove!')
                return
            end
            % clobber the existing cnf
            fod = fopen(RemoraConfFile,'w');
            for rem=1:size(remlist,1)
                if strcmp(char(remlist{rem,1}),removedRemDir)
                    [ ~, RemoraName ] = fileparts(removedRemDir);
                    disp_msg(sprintf('Removing remora from cnf file: %s', RemoraName));
                else
                    warndlg('Remora already deleted from .cnf file');
                    fprintf(fod,'%s\n',char(remlist{rem,1}));
                end
            end
            fclose(fod);
            savepath;
            restart_triton_dlg();
        else
            % user hit cancel
            cd(dir1);
            return;
        end
        return;
        
    case 'list_remoras'
        fid = fopen(RemoraConfFile,'r');
        remlist = textscan(fid,'%s','delimiter','\n');
        remlist = remlist{1,1}; % simplifies indexing
        %msgbox(remlist,'Installed Remoras');
        disp_msg('Installed Remoras:');
        cellfun(@(x) disp_msg(x),remlist);
        fclose(fid);
        
end
end % end function

function restart_triton_dlg()
    q_msg = [ 'Warning, Triton needs to be restarted after adding Remora' ...
        ' for changes to take affect.  Restart after adding Remora?' ];
    yes_msg = 'Yes';
    no_msg = 'No, restart manually later';
    restart_button = questdlg(q_msg,...
        'Restart Triton?', yes_msg, ...
        no_msg, yes_msg);
    if strcmp(restart_button,yes_msg)
        triton;
    elseif strcmp(restart_button, no_msg)
        disp_msg('Restart Triton');
    end
end