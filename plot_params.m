function plot_params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% plot_params
%
% Saves and reads the control paramters as an ascii text file.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES VERSION
% if VERSION.check == 1 %is the function being called for integrity check?
%     if VERSION.base == current_version
%         return;
%     else
%         disp('Warning, ctrlParams is out of date')
%         return;
%     end
% end
%get which plots are open
savalue = get(HANDLES.display.ltsa,'Value');
tsvalue = get(HANDLES.display.timeseries,'Value');
spvalue = get(HANDLES.display.spectra,'Value');
sgvalue = get(HANDLES.display.specgram,'Value');
%initialize to ignore nothing
ignore = 'none';

if savalue == 0
    ignore = 'LTSA';%if no LTSA not ignore
    
    % checks to see if current control window has WAV file data open
elseif sgvalue + tsvalue + spvalue == 0
    ignore = 'wav';%if not ignore
end

%get what the user wants to do.
button = questdlg(['Would you like to save, load or make current ',...
    'control parameters default'], ...
    'Control Parameters', 'Save', 'Load', 'Make Default', 'Save');
filterSpec = '.cp.txt';


if strcmp(button,'Load')
    [fileName, path] = uigetfile(['*',filterSpec],'Pick saved file');
    if fileName == 0
        return %user hit cancel
    end
    %make sure it's in the right format
    if strfind(fileName, filterSpec) == 0
        disp_msg('Error file must be in .cp format');
        return;
    end
    
    fid = fopen([path fileName]);
    
    if fid == -1
        fprintf('Couldn''t open %s', fileName)
        return
    end
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
    
    
elseif strcmp(button,'Make Default')
    disp('entered')
    button = 'Save';
%     infile = which('saved.def.txt');
    infile = fullfile(PARAMS.path.Settings,'saved.def.txt');
end

if strcmp(button,'Save')
    if ~exist('infile','var')%exists only when user is saving to default
        [fileName, path] = uiputfile(['*',filterSpec],'Pick where to save file');
        if fileName == 0
            return %user hit cancel
        end
        infile = [path fileName];
    end
    
    %open file
    fid = fopen(infile, 'w');
    if fid == -1
        fprintf('Couldn''t open %s at %s\n', infile, path)
        return
    end
    %open the template
%     fidTemp = fopen(which('saved.def.cp.txt'),'r');
    fidTemp = fopen(fullfile(PARAMS.path.Settings,'saved.def.cp.txt'),'r');
    if fidTemp == -1
        disp('Error - no file defaulttxt')
        return
    end
    %loops of template and puts the value of the current params in then
    %writes them to the userspecified place.
    while ~feof(fidTemp)
        tline = fgets(fidTemp);
        par = strfind(tline,'PARAMS'); %finds the params
        equal = strfind(tline,'=');
        semi = strfind(tline,';');
        cmap = strfind(tline,'cmap');
        if (~isempty(equal))
            if isempty(cmap)
                writeLine = [tline(1:equal), ' ', num2str(eval(tline(par:equal-1))), ...
                                        tline(semi:length(tline))];
            else
                index = get(HANDLES.amp.cmap, 'Value');%need numeric represetaino of color
                writeLine = [tline(1:equal), ' ', num2str(index), tline(semi:length(tline))];
            end
        else
            writeLine = tline;
        end
        
        fprintf(fid, '%s', writeLine);
    end
    
    fclose(fidTemp);
    fclose(fid);
    disp_msg('Control Parameters have been saved');
end

end

