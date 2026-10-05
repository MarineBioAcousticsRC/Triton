function batchLTSA_mk_ltsa_dir(lIdx)
% BATCHLTSA_MK_LTSA_DIR   Create LTSA from audio files
%
%   Syntax:
%       BATCHLTSA_MK_LTSA_DIR(LIDX)
%
%   Description:
%       Create an LTSA for a single directory (lIdx) of the many
%       directories selected in the batchLTSA set up process. 
%
%       This creates a single progress bar for this LTSA and will create a
%       single LTSA output file if single channel data or only one channel
%       being processed, but will simultaneously make LTSAs for all
%       channels if multichannel data and all channels was specified. 
%
%       This was modified from Ann Allen 1.93.20190212. 
%
%   Inputs:
%       calls global PARAMS and REMORA
%       lIdx    [double] index of which LTSA (of the set to be batch
%               processed) to make
%
%	Outputs:
%       updates global PARAMS and REMORA, write to .ltsa file
%
%   Examples:
%
%   See also BATCHLTSA_CALC_LTSA_DIR
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   04 May 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS REMORA
tic

% initiate loadbar showing progress
h = loadbar(['Creating LTSA ',num2str(lIdx),'/', ...
    num2str(length(REMORA.batchLTSA.ltsa.indirs))]);
pcntDone = 0;
loadbar(['Calculating, ',num2str(int8(pcntDone*100)),'% complete'],h, pcntDone)

% data type
if PARAMS.ltsa.ftype == 1
    d = dir(fullfile(PARAMS.ltsa.indir, '*.wav')); % wav files
elseif PARAMS.ltsa.ftype == 3
    d = dir(fullfile(PARAMS.ltsa.indir, '*.flac')); % flac files
elseif PARAMS.ltsa.ftype == 2
    d = dir(fullfile(PARAMS.ltsa.indir,'*.x.wav'));    % xwav files
end

% clean up PARAMS.ltshd for this directory
if isfield(PARAMS,'ltsahd')
    PARAMS = rmfield(PARAMS,'ltsahd');
end
% also clean up some items in PARAMS.ltsa (in case left over from before)
PARAMS.ltsa.nch = [];
PARAMS.ltsa.nave = [];
PARAMS.ltsa.byteloc = [];
PARAMS.ltsa.fname = char(d.name);      % file names in directory

info = audioinfo(fullfile(PARAMS.ltsa.indir, PARAMS.ltsa.fname(1,:)));
PARAMS.ltsa.fs = info.SampleRate;
PARAMS.ltsa.nfft = PARAMS.ltsa.fs / PARAMS.ltsa.dfreq;
% compression factor (cfact = 1000 for tave=5sec,fs=200000Hz,dfreq=200)
PARAMS.ltsa.cfact = PARAMS.ltsa.tave * PARAMS.ltsa.fs / PARAMS.ltsa.nfft;

% % read data file headers
get_headers; % check headers

ck_ltsaparams; % check params

% number of frequencies in each spectral average:
if mod(PARAMS.ltsa.nfft,2) % odd
    PARAMS.ltsa.nfreq = (PARAMS.ltsa.nfft + 1)/2;
else        % even
    PARAMS.ltsa.nfreq = PARAMS.ltsa.nfft/2 + 1;
end

% set spec settings
PARAMS.ltsa.window = hanning(PARAMS.ltsa.nfft);
PARAMS.ltsa.overlap = 0;
PARAMS.ltsa.noverlap = round((PARAMS.ltsa.overlap/100)*PARAMS.ltsa.nfft);

PARAMS.ltsa.sampPerAve = PARAMS.ltsa.tave * PARAMS.ltsa.fs;

total = PARAMS.ltsa.nxwav;
PARAMS.ltsa.rfNum = 0;     % total number of raw file counter
count = 0;                 % total number of averages counter for output display

% if audioinfo says 1 channel, confirm numCh is 'single'
if info.NumChannels == 1 && strcmp(REMORA.batchLTSA.settings.numCh, 'multi')
    REMORA.batchLTSA.settings.numCh = 'single';
    REMORA.batchLTSA.ltsa.chs = ones(length(REMORA.batchLTSA.ltsa.chs), 1);
    PARAMS.ltsa.ch = 1;

    disp_msg('Incorrect number of channels for single channel data.');
    disp_msg('Setting to channel 1 - output filename may still contain incorrect channel label.')
end

% if multichannel AND making LTSAs for all channels, need modified filenames
% and to loop through to write LTSA headers
if strcmp(REMORA.batchLTSA.settings.numCh, 'multi') && PARAMS.ltsa.ch == 0
    % confirm its multichannel data
    if info.NumChannels > 1  && PARAMS.ltsa.ch == 0
        nch = info.NumChannels;
        % set up output of all by-channel file names and fods
        PARAMS.ltsa.outfiles_ch = {};
        PARAMS.ltsa.fods = zeros(nch, 1);
        curr_ofile = PARAMS.ltsa.outfile;
        % generate file names and write ltsa headers
        for ich = 1:nch
            % clean up curr_ofile
            curr_ofile =  strrep(curr_ofile,'.ltsa',''); 
            curr_ofile = strrep(curr_ofile, '_ch0','');
            % append ch# on end
            new_ofile = sprintf('%s_ch%d.ltsa',curr_ofile, ich);

            PARAMS.ltsa.outfiles_ch{ich} = new_ofile;
            PARAMS.ltsa.fods(ich) = fopen(fullfile(PARAMS.ltsa.outdir, new_ofile), 'w');

            % write header portion of ltsa for each ltsa
            PARAMS.ltsa.outfile = new_ofile;
            PARAMS.ltsa.ch = ich;
            write_ltsahead;
        end
    else
        disp_msg('Issue with multichannel data. Exiting.');
        disp_msg('See batchLTSA_mk_ltsa_dir L75 and contact Selene Fregosi.')
    end

    % if single channel or only processing one channel, write that header
elseif strcmp(REMORA.batchLTSA.settings.numCh, 'single ') || ...
        info.NumChannels == 1 || PARAMS.ltsa.ch > 0
    nch = 1;
    PARAMS.ltsa.fods = zeros(nch, 1);
    PARAMS.ltsa.fods(nch) = fopen(fullfile(PARAMS.ltsa.outdir, ...
        PARAMS.ltsa.outfile), 'w');
    write_ltsahead;
end

% loop over xwavs and raw files or wavs/flacs
% multichannel LTSAs will be created simultaneously
for k = 1:PARAMS.ltsa.nxwav

    % globalize xwav # we're on so can access in calc_ltsa
    PARAMS.ltsa.currxwav = k;

    % HARP and ARP & OBS data
    if PARAMS.ltsa.ftype == 2
        % open xwav file
        PARAMS.ltsa.fid = fopen(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)),'r');
        fseek(PARAMS.ltsa.fid,80,'bof');
        nrf = fread(PARAMS.ltsa.fid,1,'uint16');         % Number of RawFiles in XWAV file (80 bytes from bof)
    else % wav or flac data
        nrf = 1;
        PARAMS.ltsa.fid = fopen(fullfile(PARAMS.ltsa.indir, PARAMS.ltsa.fname(k,:)), 'r');
    end

    % loop over each raw file in xwav (nrf = 1 for wavs)
    for r = 1:nrf
        PARAMS.ltsa.rfNum = PARAMS.ltsa.rfNum + 1; % total # of raw files processed

        % skip rfs we want to skip
        if ismember(PARAMS.ltsa.rfNum, PARAMS.ltsa.rf_skip)
            continue;
        end

        if PARAMS.ltsa.ftype ~= 1 && PARAMS.ltsa.ftype ~= 3     % xwavs
            nave1 = (PARAMS.ltsahd.write_length(PARAMS.ltsa.rfNum) * ...
                PARAMS.ltsa.blksz / PARAMS.ltsa.nch)/(PARAMS.ltsa.nfft * PARAMS.ltsa.cfact);
        else                                                    % wavs or flacs
            nave1 = PARAMS.ltsahd.nsamp(PARAMS.ltsa.rfNum)/...
                (PARAMS.ltsa.nfft * PARAMS.ltsa.cfact);
        end

        % difference the number of averages and size of raw file
        dnave = PARAMS.ltsa.nave(PARAMS.ltsa.rfNum) - nave1;

        % loop over channels
        for ich = 1:nch
            PARAMS.ltsa.fod = PARAMS.ltsa.fods(ich);
            if nch > 1
                PARAMS.ltsa.ch = ich;
            end

            % jump to correct place in output file to put spectral averages
            fseek(PARAMS.ltsa.fod, PARAMS.ltsa.byteloc(PARAMS.ltsa.rfNum), 'bof');
            xi = 0;

            % loop over averages
            for n = 1:PARAMS.ltsa.nave(PARAMS.ltsa.rfNum)

                % globalize for use in calc_ltsa
                PARAMS.ltsa.currNave = n;

                % increment ltsa count from mk_ltsa
                count = count + 1;

                % number of samples to grab
                if dnave == 0       % number of averages divide evenly into size of raw file
                    nsamp = PARAMS.ltsa.sampPerAve;
                else
                    if n == PARAMS.ltsa.nave(PARAMS.ltsa.rfNum)     % last average, data not full number of samples
                        %                     nsamp = (PARAMS.ltsahd.nsectPerRawFile(r) * 250) - ((PARAMS.ltsa.nave(r) - 1) * PARAMS.ltsa.sampPerAve);
                        if PARAMS.ltsa.ftype ~= 1 && PARAMS.ltsa.ftype ~= 3 % xwavs
                            nsamp = (PARAMS.ltsahd.write_length(PARAMS.ltsa.rfNum)...
                                * PARAMS.ltsa.blksz / PARAMS.ltsa.nch) - ...
                                ((PARAMS.ltsa.nave(PARAMS.ltsa.rfNum) - 1) * PARAMS.ltsa.sampPerAve);
                        else                                                % wavs or flacs
                            nsamp = PARAMS.ltsahd.nsamp(PARAMS.ltsa.rfNum)  - ...
                                ((PARAMS.ltsa.nave(PARAMS.ltsa.rfNum) - 1) * PARAMS.ltsa.sampPerAve);
                        end
                        PARAMS.ltsa.dur = nsamp / PARAMS.ltsa.fs;
                    else
                        nsamp = PARAMS.ltsa.sampPerAve;
                    end
                end

                % disp([num2str(k),'  ',num2str(r),'  ',num2str(n),'  ',num2str(nsamp)])      % for debugging

                if PARAMS.ltsa.ftype ~= 1 && PARAMS.ltsa.ftype ~= 3            % xwavs (count bytes)
                    % start Byte location in xwav file of spectral average
                    if n == 1
                        xi = PARAMS.ltsahd.byte_loc(PARAMS.ltsa.rfNum);
                    else
                        %                     xi = xi + (bytesPerAve * PARAMS.ltsa.nch);
                        xi = xi + (nsamp * (PARAMS.ltsa.nBits/8) * PARAMS.ltsa.nch);
                    end
                else                    % wav or flac files (count samples)
                    if n == 1
                        yi = 1;
                    else
                        %                     yi = yi + PARAMS.ltsa.sampPerAve;
                        yi = yi + nsamp;
                    end
                end

                % hold on to number of samples to calculate next byte location
                prev_nsamp = nsamp;

                % clear data vector
                data = [];

                % jump to correct location in xwav file
                if PARAMS.ltsa.ftype == 2
                    fseek(PARAMS.ltsa.fid,xi,'bof');
                    data = fread(PARAMS.ltsa.fid,[PARAMS.ltsa.nch,nsamp],PARAMS.ltsa.dbtype);
                else
                    [dall, ~] = audioread(fullfile(PARAMS.ltsa.indir, ...
                        PARAMS.ltsa.fname(k,:)), [yi yi-1+nsamp], 'native' );
                    dall = double(dall);
                    data = dall(:, PARAMS.ltsa.ch);
                end

                % no data - error message
                if ~isempty(data)
                    %                 data = data(PARAMS.ltsa.ch,:);
                    data = data';
                else
                    disp_msg(['Error: No data read, # of samples = ',num2str(nsamp)])
                    disp_msg(['xi = ',num2str(xi)])
                    disp_msg(['k,r,n = ',num2str(k),' ',num2str(r),' ',num2str(n)])
                    data = zeros(1,nsamp);
                end

                % write ltsa values
                batchLTSA_calc_ltsa_dir(data);
            end
        end % all channels
    end % all raw files within xwav

    fclose(PARAMS.ltsa.fid);
    fprintf('Completed processing sound file %d\n', k);
    % update loadbar
    pcntDone = k/PARAMS.ltsa.nxwav;
    loadbar(['Calculating, ',num2str(int8(pcntDone*100)),'% complete'],h, pcntDone)
end %loop through all sound files

% close output ltsa file
fclose all;

t = toc;
t = t/60/60;
disp_msg(['Time to calculate ',num2str(count),' spectra is ', num2str(t),' h']);
% turn off progress bar (loadbar)
close(h)

end