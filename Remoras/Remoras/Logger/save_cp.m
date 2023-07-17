function save_cp(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% save_cp.m
%
% Saves the control parameters reads them from
% ascii text file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS HANDLES

filterSpec = '.cp.txt';

% if user decides to pick which .cp file they want to read
if strcmp(action,'readPick')
    boxTitle1 = 'Pick saved file';
    dir1 = cd; %saves current working directory
    [PARAMS.cp.infile,PARAMS.cp.inpath]=uigetfile(['*',filterSpec],boxTitle1);

    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(PARAMS.cp.infile),'0')
        return
        %checks that the file is a .cp txt file
    elseif strfind(PARAMS.cp.infile, filterSpec) == 0
        disp_msg('Error file must be in .cp format')
        return
    end
    cd(PARAMS.cp.inpath); %switches to the directory with the .cp file in it
    save_cp('read')
    cd(dir1);


%this sets all the data back to their default numbers
elseif strcmp(action,'readDefault')
    PARAMS.cp.infile = 'saved.def.txt';
    save_cp('read')

elseif strcmp(action,'read')

    savalue = get(HANDLES.display.ltsa,'Value');
    tsvalue = get(HANDLES.display.timeseries,'Value');
    spvalue = get(HANDLES.display.spectra,'Value');
    sgvalue = get(HANDLES.display.specgram,'Value');

    [fid,message] = fopen(PARAMS.cp.infile, 'r');
    if message == -1
        disp(['Error - no file ',filename])
        return
    end

    ignore = 'none';
    if savalue + tsvalue + spvalue + sgvalue < 1
        % else do not continue until an LTSA, XWav or wav file is open
         disp_msg('Error - please open an LTSA, XWav or Wav file first')
         return
    % checks to see if current control window has LTSA data open
    elseif savalue == 0
        ignore = 'LTSA';
        % checks to see if current control window has WAV file data open
    elseif sgvalue + tsvalue + spvalue == 0
        ignore = '(wav)';
    
    end
    
    %reads the text file
    while ~feof(fid)            % not EOF
        tline=fgets(fid);
        e = strfind(tline,'=');
        c = strfind(tline,';');
        h = strfind(tline,'HANDLES');
        p = strfind(tline,'PARAMS');
        
        %looks for lines containing data that are not implemented
        leave = strfind(tline,ignore);

        %inputs the data into the control window
        if ~isempty(h) && ~isempty(e) && isempty(leave)
            
            par = tline(p:c);
            hLine = strtrim(tline(h:length(tline))); %contains the HANDLES line
            pLine = strtrim(tline(e+1 : c-1)); %contains the PARAMS data
            if isempty(strfind(hLine,'cmap'))
                set(eval(hLine),'String',eval(pLine)) %set the data into the control window
            end
           
            if isempty(strfind(par,'freq'))
                eval(par);
            end
            
%         elseif isempty(leave)
%             eval(tline); %calls all the control parameters that need to be checked
        end
    end
    fclose(fid);
   if sgvalue + tsvalue + spvalue > 0 % only do a check if an Xwav or Wav file is open
   control('newstfreq');
   control('newendfreq');
   control('newtseg');
   end
   
   if savalue % only do a check if an LTSA file is open
   control_ltsa('newstfreq');
   control_ltsa('newendfreq');
   control_ltsa('newtseg');
   end

    
%saving file to desired directory
elseif strcmp(action,'saveTo')
    boxTitle1 = 'Saving paramaters to';
    dir1 = cd;
    [PARAMS.cp.infile,PARAMS.cp.inpath]=uiputfile(['*',filterSpec],boxTitle1);

    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(PARAMS.cp.infile),'0')
        return
        %checks to see if it is a .cp file
    elseif strfind(PARAMS.cp.infile, filterSpec) == 0
        disp_msg('Error file must be in *.cp format')
        return
    end
    cd(PARAMS.cp.inpath);
    save_cp('write')
    cd(dir1);

    %writes the data onto a .cp text file
elseif strcmp(action,'write')
    savalue = get(HANDLES.display.ltsa,'Value');
    tsvalue = get(HANDLES.display.timeseries,'Value');
    spvalue = get(HANDLES.display.spectra,'Value');
    sgvalue = get(HANDLES.display.specgram,'Value');
    
    % check to see if an LTSA, XWav or Wav file is open
    if savalue + tsvalue + spvalue + sgvalue < 1
        disp_msg('Error - please open an LTSA, XWav or Wav file first')
        return
    end
% open the master template for all.cp.txt files
    [fid,message] = fopen('saved.def.txt', 'r'); 
    if message == -1
        disp(['Error - no file defaulttxt'])
        return
    end
%create or ovewrite existing .cp file
    fid2 = fopen(PARAMS.cp.infile,'w');

    while ~feof(fid)            % not EOF
        tline=fgets(fid);
        par = strfind(tline,'PARAMS'); %finds the params
        k = strfind(tline,'=');
        e = strfind(tline,';');
%         disp(tline);
        %checks to see if there were params in the line
        if (~isempty(k))
            % write in new data into .cp file
            a = [tline(1:k),' ', num2str(eval(tline(par:k-1))), tline(e : length(tline))];
        else
            a = tline;
        end

        fprintf(fid2, '%s', a);
    end

    fclose(fid);
    fclose(fid2);
    disp_msg(['Control Parameters have been saved']);

end
