function sm_cmpt_diary

%%%%%%%%%%%%%%%%%%%%%%%
% sm_cmpt_diary
%
% create output text file with all variables
%
%%%%%%%%%%%%%

global REMORA PARAMS

%Directories and Files
% start time of computation
disp(['Computation start local time: ',datestr(now)])
disp('---')

% In- and out directory and file info
disp(['Analysis files to be saved to: ' REMORA.sm.cmpt.outdir])
disp('---')

disp(['Analyzing all LTSA files in ' REMORA.sm.cmpt.indir]);
disp('---')

disp(REMORA.sm.cmpt.FileList) %Display all wav files in directory
disp('---')

% output of csv and/or ltsa
if REMORA.sm.cmpt.ltsaout
    disp('Output of LTSA file(s)')
end
if REMORA.sm.cmpt.csvout
    disp('Output of .csv file(s)')
end
disp('---')

%Bandpass Edges
disp(['Lower and upper frequency limits of calculation: ',...
    num2str(REMORA.sm.cmpt.lfreq), '-', num2str(REMORA.sm.cmpt.hfreq),' Hz'])
disp('---')

% Bin Size Time
disp(['Time bin size is ', num2str(REMORA.sm.cmpt.avgt),' s']);
disp('---')

% Bin Size Frequency
disp(['Frequency bin size for PSD calculation is ', num2str(REMORA.sm.cmpt.avgf),' Hz']);
disp('---')

% Percentag Coverage
disp(['Time overage for a bin to be computed needs to be ', num2str(REMORA.sm.cmpt.perc*100), '%']);
disp('---')

%Analysis types
disp('Output of the following analysis types:');
if REMORA.sm.cmpt.psd == 1
    disp('Power spectral density in dB re 1uPa^2/Hz')
end
if REMORA.sm.cmpt.bb == 1
    disp('Broadband level in dB re 1uPa')
end
if REMORA.sm.cmpt.ol == 1
    disp('Octave band level in dB re 1uPa')
end
if REMORA.sm.cmpt.tol == 1
    disp('Third octave band level in dB re 1uPa')
end
disp('---')

%Averaging types
disp('Computation of the following averaging types:');
if REMORA.sm.cmpt.mean == 1
    disp('Mean')
end
if REMORA.sm.cmpt.median == 1
    disp('Median')
end
if REMORA.sm.cmpt.prctile == 1
    disp('Percentiles')
end
disp('---')

%Removel of erroneous data types
disp('Removal of the following erroneous data types:');
if REMORA.sm.cmpt.fifo == 1
    disp('First in / First out - FIFO noise')
end
if REMORA.sm.cmpt.dw == 1
    disp('Disk writes in HARP data')
end
if REMORA.sm.cmpt.strum == 1
    disp('Strumming and/or flow noise')
end
disp('---')

%Calibration yes/no
if REMORA.sm.cmpt.cal
    cal = 'yes';
    disp(['Calibration of data: ', cal]);
    if REMORA.sm.cmpt.sval
        disp(['Single value full system calibration: ',...
            num2str(REMORA.sm.cmpt.caldb),' dB'])
    else
        disp(['Transfer function calibration - file: ',...
            fullfile(REMORA.sm.cmpt.tpath,REMORA.sm.cmpt.tfile)])
    end
else
    cal = 'no';
    disp(['Calibration of data: ', cal]);
end


disp('---')

disp('Start analyzing...')

