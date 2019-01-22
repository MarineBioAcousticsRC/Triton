function miscpd(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% miscpd.m
%
% the callback for all the misc pulldown actions.
%
% Parameters:
%         action - a string that is the action to be preformed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES DATA

switch action
  case 'dispAbout'
    % window placement & size on screen
    defaultPos=[0.35,0.125,0.25,0.313];
    % open and setup figure window
    HANDLES.fig.Misc =figure( ...
      'NumberTitle','off', ...
      'MenuBar','none',...
      'Name',['Help - Triton ',PARAMS.ver],...
      'Units','normalized',...
      'Position',defaultPos);
    
    str1 = {['Triton Version ',PARAMS.ver]};
    
%     str2(1) = {'<a href = "http://cetus.ucsd.edu\/technologies_Software.html" Triton Software Website</a>'};
    str2(1) = {'Triton Website: http://cetus.ucsd.edu/technologies\_Software.html'};
    str2(2) = {' '};
    str2(3) = {'Triton Email: cetus@ucsd.edu'};
    strPos= [0.025 0.05 0.95 0.90];
    
    logofn = fullfile(PARAMS.path.Extras,'Triton_logo.jpg');
    if exist(logofn)
      image(imread(logofn))
      axis off
    end
    
    FS = 8;
    text(50,50,str1,'FontSize',FS)
    text(50,750,str2,'FontSize',FS)
    
  % Save the current window settings
  case 'save_settings'
    [saveFile, savePath] = uiputfile('.txt');
    if saveFile == 0
      return;%user canceled input
    end
    fullPath = fullfile(savePath, saveFile);
    fid = fopen(fullPath, 'w+');
    
    %write position vectors to file.
    for x=1:3
      pos = get(x, 'Position');
      fprintf(fid, '[%d %d %d %d]\n', pos);
    end
    fclose(fid);
  
  % Load window settings to file.    
  case 'load_settings'
      [fileName, path] = uigetfile('.txt');
      if fileName == 0
          return;%user canceled input
      else
          fid = fopen([path fileName]);
      end

    
    idx = 1;
    while ~feof(fid)
      tmp = eval(fgetl(fid));%read postion vector
      set(idx, 'Position', tmp);%move the windows
      idx = idx + 1;%increment to next window
    end
    fclose(fid);
  
  % Make the current window settings the default settings    
  case 'set_startup'
%     rootDir = fileparts(which('triton'));
    settings = fullfile(PARAMS.path.Settings, 'defaultWindow.tconfig');
    fid = fopen(settings, 'w');
    if fid ~= -1
      for x=1:3
        set(x,'Units', 'normalized');
        pos = get(x, 'Position');
        fprintf(fid, '[%d %d %d %d]\n', pos);
      end
    else
      disp('Couldn''t create a settings file');
    end
    fclose(fid);
    
  case 'default_windows'
    set(1,'Position', [0.3344 0.05 0.65 0.875])
    set(2,'Position',[0.025 0.35 0.3 0.6])
    set(3, 'Position',[0.025 0.05 0.3 0.25])
    
  case 'plot_params'
    set(HANDLES.fig.ctrl, 'Pointer', 'watch');
    set(HANDLES.fig.main, 'Pointer', 'watch');
    set(HANDLES.fig.msg, 'Pointer', 'watch');
    plot_params
    set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
    set(HANDLES.fig.main, 'Pointer', 'arrow');
    set(HANDLES.fig.msg, 'Pointer', 'arrow');
    
  case 'default_params'
%     TritonPath = fileparts(which('triton'));
%     TritonSettingsPath = fullfile(TritonPath,'Settings');
%     DefaultParams = fullfile(TritonSettingsPath, 'DefaultPARAMS.cp.txt');
    DefaultParams = fullfile(PARAMS.path.Settings, 'DefaultPARAMS.cp.txt');
    fid = fopen(DefaultParams);
    %preallocate callBack cell array.
    callBack = cell(15,1);
    callIdx = 1;
    while ~feof(fid)
        line = fgetl(fid);
        ignoreThisLine = strfind(line, ignore);
        cmapLine = strfind(line, 'cmap');%special things have to been for color param
        if isempty(ignoreThisLine)
            %find the semicolon and equals location location
            semicolon = strfind(line,';');
            equal = strfind(line, '=');
            
            %get the JUST the value of the parameter
            param = strtrim(line(equal + 1 : semicolon -1));
            %next line should contain the handle that needs to be set to
            %the above param value.
            line = fgetl(fid);
     
            %trim to just have the handle as a string
            percent = strfind(line,'%');
            handle = eval(strtrim(line(1 : percent - 1)));
            
            %set the text in the handle to the desired param setting
            if isempty(cmapLine)
                set(handle, 'String', eval(param));
            else
                
                set(handle, 'Value', eval(param));
            end
            %store each callback to be called later
            callBack{callIdx} = get(handle, 'Callback');
            callIdx = callIdx + 1;
            fgetl(fid);%skip the blank line
        else
            %skip past the next two lines as they are ignored
            fgetl(fid);
            fgetl(fid);
        end
    end
    
    %removes empty cells by calling ~isempty on each cell 
    callBack = callBack(~cellfun('isempty',callBack));
    %removes repeated callbacks
    callBack = unique(callBack);
    if sgvalue == 0
        ignoreCall = 'control(''ampadj'')';
    else
        ignoreCall = 0;
    end
    
    for idx=1:length(callBack)
        if ~strcmp(callBack{idx}, ignoreCall)
            eval(callBack{idx});
        end
    end
    fclose(fid);
   
  case 'export_mat'
    [DataFile, DataPath] = uiputfile('data.mat');
    if DataFile == 0
      return;
    end
    save(fullfile(DataPath, DataFile),'DATA');
    
  case 'export_params'
    [ParamsFile, ParamsPath] = uiputfile('params.mat');
    if ParamsFile == 0
      return;
    end
    save(fullfile(ParamsPath,ParamsFile),'PARAMS');

end

