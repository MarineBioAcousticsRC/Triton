function decimatewav_dir(wavType)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% decimatexwav_dir.m
%
% Decimate a directory of wav, flac, or xwav files.
%
% Parameters:
%       wavType - a string that is either 'wav' or 'xwav' depending on the
%                       type of file you are decimating.
%               - works with flac files, treated similar to 'wav'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS
% get input directory with only x.wav files
%
ii = 1;
PARAMS.ddir = 'C:\';     % default directory
PARAMS.idir{ii} = uigetdir(PARAMS.ddir,['Select Directory ',num2str(ii),...
    ' with only ' wavType ' files']);
% if the cancel button is pushed, then no file is loaded so exit this script
if strcmp(num2str(PARAMS.idir{ii}),'0')
    disp_msg('Canceled Button Pushed - no directory for PSD output file')
    return
else
    disp_msg('Input file directory : ')
    disp_msg([PARAMS.idir{ii}])
    %     disp(' ')
end
% get info on xwav/wav files in dir
if strcmp(wavType,'wav')
    d = dir(fullfile(PARAMS.idir{ii},['*.' wavType])); % directory info
    if isempty(d)
        d = dir(fullfile(PARAMS.idir{ii},'*.flac'));    % maybe flac files?
        if ~isempty(d)
            wavType = 'flac'; % if it is flac files, update waveType
        end
    end
else
    d = dir(fullfile(PARAMS.idir{ii},['*.' wavType]));    % directory info
end

PARAMS.fname{ii} = char(d.name);                % file names
fnsz = size(PARAMS.fname{ii});
PARAMS.nfiles{ii} = fnsz(1);   % number of files in directory

disp_msg(['Number of ' wavType ' files in Input file directory is ',...
    num2str(PARAMS.nfiles{ii})])

PARAMS.inpath = [PARAMS.idir{ii},'\'];
% first file's sample rate
PARAMS.infile = deblank(PARAMS.fname{ii}(1,:));
if strcmp(wavType,'wav')
    PARAMS.ftype = 1;   % files are xwavs
    rdwavhd        % get datafile info
elseif strcmp(wavType, 'flac')
    PARAMS.ftype = 3;
    % pull relevent info that would come vrom rdwavhd
    info = audioinfo([PARAMS.inpath PARAMS.infile]);
    PARAMS.nch = info.NumChannels;         % Number of Channels
    PARAMS.fs = info.SampleRate;          % Sampling Rate(samples/second)
else
    PARAMS.ftype = 2;
    rdxwavhd
end


% get user input decimation factor
PARAMS.df = 100; % initial decimation factor

% user input dialog box
prompt={'Enter Decimation Factor (integer) : '};
def={num2str(PARAMS.df)};
dlgTitle=[num2str(PARAMS.fs),' = Original Sample Rate',];
lineNo=1;
AddOpts.Resize='on';
AddOpts.WindowStyle='normal';
AddOpts.Interpreter='tex';
in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
if length(in) == 0	% if cancel button pushed
    return
end

% decimation factor
PARAMS.df = str2num(deal(in{1}));
% need to check that df is integer
if PARAMS.df - floor(PARAMS.df) ~= 0
    disp_msg([num2str(PARAMS.df),'  is not an integer - try again'])
    return
end


% get output directory for decimated x.wav files
%
PARAMS.odir{ii} = uigetdir(PARAMS.ddir,['Select Directory ',num2str(ii),...
    ' for Output Decimated ' wavType ' files']);
% if the cancel button is pushed, then no file is loaded so exit this script
if strcmp(num2str(PARAMS.odir{ii}),'0')
    disp_msg('Canceled Button Pushed - no directory for PSD output file')
    return
else
    disp_msg('Output decimated file directory : ')
    disp_msg([PARAMS.odir{ii}])
    %     disp(' ')
end
PARAMS.outpath = [PARAMS.odir{ii},'\'];

disp_msg('This takes a while, please wait')
tic % start stopwatch timer
h = loadbar([' Decimating ' wavType ' Files ']);
total = PARAMS.nfiles{ii};

if strcmp(wavType,'wav')
    extension_size = 4;
elseif strcmp(wavType,'flac')
    extension_size = 5;
elseif strcmp(wavType, 'x.wav')
    extension_size = 6;
end


% loop over the files and
% get header info, start time, data byte loc and byte length
for jj = 1:PARAMS.nfiles{ii}
    disp_msg(['File Number ', num2str(jj)])
    % these needed for rdxwavhd
    PARAMS.infile = deblank(PARAMS.fname{ii}(jj,:)); % get file names sequentally
    PARAMS.outfile = [PARAMS.infile(1:length(PARAMS.infile)-extension_size),'.d',...
        num2str(PARAMS.df),'.' wavType];
    PARAMS.xhd.dSubchunkSize = [];
    if strcmp(wavType, 'wav') || strcmp(wavType, 'flac')
%         rdwavhd % this used to check df but now that is checked above
        %Decimating wav files is easy
        %         [data,fs,nbits]=wavread([PARAMS.inpath,PARAMS.infile],'native');
        [data,fs] = audioread([PARAMS.inpath,PARAMS.infile], 'native');
        data = double(data);
        info = audioinfo([PARAMS.inpath,PARAMS.infile]);
        nbits = info.BitsPerSample;
        nch = info.NumChannels;
        %     odata = decimate(double(data),PARAMS.df);
        if nch == 1
            odata = decimate(double(data),PARAMS.df);
        else
            for m = 1:nch
                odata(:,m) = decimate(double(data(:,m)),PARAMS.df);
            end
        end
        
        new_fs = fs/PARAMS.df;
        if nbits == 16
            %             wavwrite(int16(odata), new_fs, nbits, [PARAMS.outpath,PARAMS.outfile]);
            audiowrite([PARAMS.outpath,PARAMS.outfile],int16(odata),new_fs,'BitsPerSample',nbits);
        elseif nbits == 24
            %             wavwrite(int32(odata), new_fs, nbits, [PARAMS.outpath,PARAMS.outfile]);
            audiowrite([PARAMS.outpath,PARAMS.outfile],int32(odata),new_fs,'BitsPerSample',nbits);
        elseif nbits == 32
            %             wavwrite(int32(odata), new_fs, nbits, [PARAMS.outpath,PARAMS.outfile]);
            audiowrite([PARAMS.outpath,PARAMS.outfile],int32(odata),new_fs,'BitsPerSample',nbits);
        else
            disp_msg('Error: bit size not supported')
            disp_msg(['Nbits = ', num2str(nbits)])
            return
        end
        clear odata
        pcntDone = (jj-1)/total;
        loadbar(['Calculating, ', num2str(int8(pcntDone*100)),...
            '% complete'], h, pcntDone)
        continue
    else
        rdxwavhd
        wrxwavhd(2)
    end
    
    %     if PARAMS.nch == 1
    %         nsamp = 15e6;       % number of samples to read for each decimation
    %         % also the number of samples in each hrp raw file
    %     elseif PARAMS.nch == 4
    %         nsamp = 3.596e6;    % number of samples per channel to read for decimation
    %     else
    %         disp_msg('Error : number of channels not 1 or 4')
    %         disp_msg(['PARAMS.nch = ',num2str(PARAMS.nch)])
    %     end
    %
    %     total_samples = PARAMS.xhd.dSubchunkSize / (PARAMS.samp.byte * PARAMS.nch);
    %
    %     dnf = total_samples /nsamp; % number of decimations -- floating point
    %
    %     dn = floor(dnf);            % integer number of decimations
    %     drem = dnf - dn;            % remainder (percentage) number of decimations
    %     if drem ~= 0
    %         disp_msg(['remainder of decimated samples ', num2str(drem)])
    %     end
    %     if (drem > 0)               % most typical case
    %         dn = dn + 1;
    %         nsampLast = floor(nsamp * drem);
    %     elseif drem == 0
    %         disp_msg('all decimations same size')
    %         nsampLast = nsamp;
    %     elseif drem < 0
    %         disp_msg('error -- not possible')
    %     end
    
    dn = PARAMS.xhd.NumOfRawFiles;
    
    disp_msg(['Number of decimations : ',num2str(dn)])
    
    % main loop to read in data from xwav, decimate, then write out to new xwav
    % file
    fid = fopen([PARAMS.inpath,PARAMS.infile],'r');
    fod = fopen([PARAMS.outpath,PARAMS.outfile],'a');   % open as append, don't need to fseek
    %     total = total + dn;
    count = 0;
    switch wavType % maybe change this in the future to one for loop with one switch/case for di == 1
        case 'wav'
            for di = 1:dn
                if di == dn
                    nsamp = nsampLast; % number of samples for last decimation
                end
                fseek(fid,PARAMS.xhd.dataIndex + (di-1)*nsamp,'bof');
                % read the data
                data = fread(fid,nsamp,precision);
                %decimate and write
                decimatedData = decimate(data,PARAMS.df); % decimated to a double which equals 32 bits
                fwrite(fod,decimatedData,precision);
                count = count + 1;
                pcntDone = ((jj-1) + count/dn)/total;
                loadbar(['Calculating, ',num2str(int8(pcntDone*100)),...
                    '% complete'],h, pcntDone)
            end
        case 'flac'
            % this never gets called because of continue after simple
            % decimation for wav and flac above. 
        case 'x.wav'
            for di = 1:dn
                %                 if di == dn
                %                     nsamp = nsampLast; % number of samples for last decimation
                %                 end
                nsamp = PARAMS.xhd.byte_length(di) ./ (PARAMS.samp.byte * PARAMS.nch);
                if rem(nsamp,PARAMS.df) ~= 0
                    nsamp = nsamp - rem(nsamp,PARAMS.df);
                end
                % jump over header and the number of decimations done so far...
                %                 fseek(fid,PARAMS.xhd.byte_loc(1) +...
                %                     (di-1)*nsamp*PARAMS.nch*PARAMS.samp.byte,'bof');
                fseek(fid,PARAMS.xhd.byte_loc(di),'bof');
                % read the data
                data = fread(fid,[PARAMS.nch,nsamp],'int16');
                %decimate and write
                if PARAMS.nch == 1
                    fwrite(fod,decimate(data,PARAMS.df),'int16');
                else
                    for m = 1:PARAMS.nch
                        ddata(m,:) = decimate(data(m,:),PARAMS.df);
                    end
                    fwrite(fod,ddata,'int16');
                end
                count = count + 1;
                pcntDone = ((jj-1) + count/dn)/total;
                loadbar(['Calculating, ',num2str(int8(pcntDone*100)),...
                    '% complete'],h, pcntDone)
            end
    end
    
    fclose(fid);
    fclose(fod);
    %     count = count+1;
    %     pcntDone = count/total;
    %     loadbar(['Calculating, ',num2str(int8(pcntDone*100)),'% complete'],h, pcntDone)
end
toc
close(h)
