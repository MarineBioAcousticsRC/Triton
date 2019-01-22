function dt_paramspd(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% dt_paramspd.m
% 
% Set Detection Parameter pull-down menus:
%   save parameter list
%   load parameter list
%
% 9/16/06 mss - from triton 1.5 paramspd.m
%
% Do not modify the following line, maintained by CVS
% $Id: dt_paramspd.m,v 1.10 2010/01/11 22:04:00 mroch Exp $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % LTSA PARAMS LOAD
    %
if strcmp(action,'LTSAparamload')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    filterSpec1 = '*.ltsa.prm';
    [PARAMS.ltsa.dt.paramfile, PARAMS.ltsa.dt.parampath] = ...
        uigetfile(filterSpec1, 'Open Triton LTSA Parameter File');
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if isscalar(PARAMS.ltsa.dt.paramfile)
      return
    end
    
    % Read in the parameter file
    PARAMS.ltsa.dt = ioLoadLTSAParams(fullfile(PARAMS.ltsa.dt.parampath, ...
                                               PARAMS.ltsa.dt.paramfile));
    if ~ isempty(PARAMS.ltsa.dt)
      % give user some feedback
      disp_msg(sprintf('Loaded LTSA Parameter File: %s', PARAMS.ltsa.dt.paramfile));
      % Populate GUI
      if isfield(PARAMS.ltsa.dt, 'Enabled') && PARAMS.ltsa.dt.Enabled
        %set parameters in detector window
        set(HANDLES.ltsa.dt.IgnPeriodic,'Value', PARAMS.ltsa.dt.ignore_periodic);
        if PARAMS.ltsa.dt.ignore_periodic
            set(HANDLES.ltsa.dt.PeriodicEdit, 'Enable', 'On')
        else
            set(HANDLES.ltsa.dt.PeriodicEdit, 'Enable', 'Off')
        end
        set(HANDLES.ltsa.dt.LPeriodEdtxt,'String', num2str(PARAMS.ltsa.dt.LowPeriod_s));
        set(HANDLES.ltsa.dt.HPeriodEdtxt,'String',  num2str(PARAMS.ltsa.dt.HighPeriod_s));
        set(HANDLES.ltsa.dt.MinFreqEdtxt,'String',  num2str(PARAMS.ltsa.dt.HzRange(1)));
        set(HANDLES.ltsa.dt.MaxFreqEdtxt,'String',  num2str(PARAMS.ltsa.dt.HzRange(2)));
        %set(HANDLES.ltsa.dt.MinDurEdtxt,'String',  num2str(PARAMS.ltsa.dt.MinDuration));
        set(HANDLES.ltsa.dt.ThresholdEdtxt,'String',  num2str(PARAMS.ltsa.dt.Threshold_dB));
        set(HANDLES.ltsa.dt.MeanSubDurEdTxt,'String',  num2str(PARAMS.ltsa.dt.MeanAve_hr));
        if PARAMS.ltsa.dt.mean_enabled
            set(HANDLES.ltsa.dt.MeanNoiseControls, 'Enable', 'Off')
        else
            set(HANDLES.ltsa.dt.MeanNoiseControls, 'Enable', 'On')
        end
        set(HANDLES.ltsa.dt.plot,'Value', PARAMS.ltsa.dt.ifPlot);
      end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % LTSA PARAMS SAVE
    %
elseif strcmp(action,'LTSAparamsave')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % user interface retrieve file to open through a dialog box
    boxTitle1 = 'Parameter Save As';
    outfiletype = '.ltsa.prm';
    [PARAMS.ltsa.dt.paramout,PARAMS.ltsa.dt.parampath]=uiputfile(['*',outfiletype],boxTitle1);
    % give user some feedback
    disp('Parameter File: ')
    disp([PARAMS.ltsa.dt.parampath,PARAMS.ltsa.dt.paramout])
    disp(' ')
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == PARAMS.ltsa.dt.paramout
        return
    end

    % fix filename extension (ALWAYS makes file name end with .ltsa.prm)
    if isempty(strfind(PARAMS.dt.paramout, outfiletype))
        % the uiputfile function does not properly handle compound
        % extensions so trim the '.prm' added automatically by uiputfile.
        if ~isempty(strfind(PARAMS.dt.paramout, '.prm'))
            PARAMS.dt.paramout = PARAMS.dt.paramout(1:end-4);
        end
        PARAMS.dt.paramout = [PARAMS.dt.paramout, outfiletype];
    end
    
    PARAMS.ltsa.dt.paramofid = fopen([PARAMS.ltsa.dt.parampath,PARAMS.ltsa.dt.paramout],'w');
    nparam=10;
    
    % done this way because Matlab compiler doesn't allow eval per load params
    fprintf(PARAMS.ltsa.dt.paramofid,'%s\n',num2str(nparam));
    fprintf(PARAMS.ltsa.dt.paramofid,'%s\n',num2str(PARAMS.ltsa.dt.ignore_periodic));
    fprintf(PARAMS.ltsa.dt.paramofid,'%s\n',num2str(PARAMS.ltsa.dt.LowPeriod_s));
    fprintf(PARAMS.ltsa.dt.paramofid,'%s\n',num2str(PARAMS.ltsa.dt.HighPeriod_s ));
    fprintf(PARAMS.ltsa.dt.paramofid,'%s\n',num2str(PARAMS.ltsa.dt.HzRange));
    %fprintf(PARAMS.ltsa.dt.paramofid,'%s\n',num2str(PARAMS.ltsa.dt.MinDuration));
    fprintf(PARAMS.ltsa.dt.paramofid,'%s\n',num2str(PARAMS.ltsa.dt.Threshold_dB));
    fprintf(PARAMS.ltsa.dt.paramofid,'%s\n',num2str(PARAMS.ltsa.dt.mean_enabled));
    if PARAMS.ltsa.dt.mean_enabled
        fprintf(PARAMS.ltsa.dt.paramofid,'%s\n',num2str(PARAMS.ltsa.dt.pwr_mean));
    end
    fprintf(PARAMS.ltsa.dt.paramofid,'%s\n',num2str(PARAMS.ltsa.dt.MeanAve_hr));
    fprintf(PARAMS.ltsa.dt.paramofid,'%s\n',num2str(PARAMS.ltsa.dt.ifPlot));

    fclose(PARAMS.ltsa.dt.paramofid);    


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % SPECTROGRAM PARAMS LOAD
    %
elseif strcmp(action,'STparamload')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    boxTitle1 = 'Open Triton Spectrogram Parameter File';
    filterSpec1 = '*.spec.prm';
    [PARAMS.dt.paramfile,PARAMS.dt.parampath]=uigetfile(filterSpec1,boxTitle1);
    % give user some feedback
    if isscalar(PARAMS.dt.paramfile)
      return    % User canceled
    end
    fname = fullfile(PARAMS.dt.parampath,PARAMS.dt.paramfile);
    ioLoadSpecgramParams(fname, HANDLES.dt);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % SPECGRAM PARAMS SAVE
    %
elseif strcmp(action,'STparamsave')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % user interface retrieve file to open through a dialog box
    boxTitle1 = 'Parameter Save As';
    outfiletype = '.spec.prm';
    [PARAMS.dt.paramout,PARAMS.dt.parampath]=uiputfile(['*',outfiletype],boxTitle1);
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == PARAMS.dt.paramout
        return
    end

    % fix filename extension (ALWAYS makes file name end with .spec.prm)
    if isempty(strfind(PARAMS.dt.paramout, outfiletype))
        % the uiputfile function does not properly handle compound
        % extensions so trim the '.prm' added automatically by uiputfile.
        if ~isempty(strfind(PARAMS.dt.paramout, '.prm'))
            PARAMS.dt.paramout = PARAMS.dt.paramout(1:end-4);
        end
        PARAMS.dt.paramout = [PARAMS.dt.paramout, outfiletype];
    end
    
    outfile = fullfile(PARAMS.dt.parampath, PARAMS.dt.paramout);
    FileHandle = fopen(outfile,'w');
    if FileHandle == -1
      errordlg(sprintf('Unable to write to file "%s"', outfile));
    else
        % Build structure to save
        detect = [];

        % Handles with String properties
        fields.string = {'MeanSubDurEdtxt';         % noise subtraction
            % tonals
            'MinDurEdtxt'; 'MinSepEdtxt';
            % broadband
            'MinTonalFreqEdtxt'; 'MaxTonalFreqEdtxt'; 'TonalThresholdEdtxt';
            'MinBBFreqEdtxt'; 'MaxBBFreqEdtxt';
            'MinBBSatEdtxt'; 'MaxBBSatEdtxt'; 'BBThresholdEdtxt'};
        % Handles with Value properties
        fields.value = {'tonals'; 'broadbands'};
                   
        % process Value properties
        for idx=1:length(fields.value)
          fprintf(FileHandle, '%s\nValue\n%d\n', fields.value{idx}, ...
                  get(HANDLES.dt.(fields.value{idx}), 'Value'));
        end
        % process String properties
        for idx=1:length(fields.string)
          fprintf(FileHandle, '%s\nString\n%s\n', fields.string{idx}, ...
                  get(HANDLES.dt.(fields.string{idx}), 'String'));
        end
      try
        1;
        
      catch
        fclose(FileHandle);
        % Display error dialog with backtrace, note failure, abort.
        guErrorBacktrace(lasterror, 'Internal error', ...
                         'Seek past end of file - contact developers');
        return
      end
      fclose(FileHandle);
      disp_msg(sprintf('Saved %s (Short time spectrum detection parameters)', ...
                       outfile));
    end
end

