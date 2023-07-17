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
global PARAMS HANDLES REMORA

% load a saved parameters file (spectrogram)
if strcmp(action,'STparamload')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    boxTitle1 = 'Open Triton Spectrogram Parameter File';
    filterSpec1 = '*.spec.prm';
    [REMORA.dt.paramfile,REMORA.dt.parampath]=uigetfile(filterSpec1,boxTitle1);
    % give user some feedback
    if isscalar(REMORA.dt.paramfile)
      return    % User canceled
    end
    fname = fullfile(REMORA.dt.parampath,REMORA.dt.paramfile);
    1;
    
    ioLoadSpecgramParams(fname, REMORA.dt);

    
% save a parameters file (spectrogram)
elseif strcmp(action,'STparamsave')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % user interface retrieve file to open through a dialog box
    boxTitle1 = 'Parameter Save As';
    outfiletype = '.spec.prm';
    [REMORA.dt.paramout,REMORA.dt.parampath]=uiputfile(['*',outfiletype],boxTitle1);
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == REMORA.dt.paramout
        return
    end

    % fix filename extension (ALWAYS makes file name end with .spec.prm)
    if isempty(strfind(REMORA.dt.paramout, outfiletype))
        % the uiputfile function does not properly handle compound
        % extensions so trim the '.prm' added automatically by uiputfile.
        if ~isempty(strfind(REMORA.dt.paramout, '.prm'))
            REMORA.dt.paramout = REMORA.dt.paramout(1:end-4);
        end
        REMORA.dt.paramout = [REMORA.dt.paramout, outfiletype];
    end
    
    outfile = fullfile(REMORA.dt.parampath, REMORA.dt.paramout);
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
                  get(REMORA.dt.(fields.value{idx}), 'Value'));
        end
        % process String properties
        for idx=1:length(fields.string)
          fprintf(FileHandle, '%s\nString\n%s\n', fields.string{idx}, ...
                  get(REMORA.dt.(fields.string{idx}), 'String'));
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

