function decimatewav(wavType)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% decimatexwav.m
%
% Decimate a wav, flac, or xwav file.
%
% Parameters:
%       wavType - a string that is either 'wav' or 'xwav' depending on the
%                       type of file you are decimating.
%               - works with flac files, treated similar to 'wav' 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS

% get file name
if strcmp(wavType, 'wav')
    filterSpec1 = ['*.wav;*.flac'];
    boxTitle1 = ['Open wav or flac file to Decimate'];
else
    filterSpec1 = ['*.',wavType];
    boxTitle1 = ['Open ', wavType, ' file to Decimate'];
end
% user interface retrieve file to open through a dialog box
%[PARAMS.infile,PARAMS.inpath]=uigetfile(filterSpec1,boxTitle1);
[infile,inpath]=uigetfile(filterSpec1,boxTitle1);

% if the cancel button is pushed, then no file is loaded
% so exit this script
if strcmp(num2str(infile),'0')
    return
else
    PARAMS.infile = infile;
    PARAMS.inpath = inpath;
    disp_msg('Opened File: ')
    disp_msg([PARAMS.inpath,PARAMS.infile])
    cd(PARAMS.inpath)
    [~,~,ext] = fileparts(PARAMS.infile);
end

if strcmp(ext,'.flac')
    wavType = 'flac'; % update wavType if flac file. 
end

if strcmp(wavType,'wav')
    PARAMS.ftype = 1;   % file is wav
    rdwavhd        % get datafile info
    if PARAMS.df == -1 % bad wav file
        return;
    end
elseif strcmp(wavType, 'flac')
    PARAMS.ftype = 3;
    % pull relevent info that would come from rdwavhd
    info = audioinfo([PARAMS.inpath PARAMS.infile]);
    PARAMS.nch = info.NumChannels;         % Number of Channels
    PARAMS.fs = info.SampleRate;          % Sampling Rate(samples/second)    
else
    PARAMS.ftype = 2;   % file is xwav
    rdxwavhd        % get datafile info
end
% get user input decimation factor
PARAMS.df = 100; % initial decimation factor
%
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
% need to check that PARAMS.df is integer
if PARAMS.df - floor(PARAMS.df) ~= 0
    disp_msg([num2str(PARAMS.df),'  is not an integer - try again'])
    return
end

disp_msg(['Orginal Sample Rate: ',num2str(PARAMS.fs)])
disp_msg(['Decimation Factor: ',num2str(PARAMS.df)])

if strcmp(wavType,'wav')
    extension_size = 4;
elseif strcmp(wavType,'flac')
    extension_size = 5;
elseif strcmp(wavType, 'x.wav')
    extension_size = 6;
end

% open new decimated output file
% base name on input file
PARAMS.outfile = [PARAMS.infile(1:length(PARAMS.infile)-extension_size),'.d',...
    num2str(PARAMS.df),'.' wavType];
% PARAMS.outfile = strcat(PARAMS.infile(1:length(PARAMS.infile)-6),'.d',...
%                                            num2str(PARAMS.df),'.',wavType);
PARAMS.outpath = PARAMS.inpath;
boxTitle2 = ['Save Decimated ' wavType ' file'];

[PARAMS.outfile,PARAMS.outpath] = uiputfile(PARAMS.outfile,boxTitle2);

if PARAMS.outfile == 0
    disp_msg(['Cancel Save Decimated ' wavType 'File'])
    return
end

disp_msg('This takes a while, please wait ...')

if ~strcmp(wavType, 'wav') && ~strcmp(wavType, 'flac')
    wrxwavhd(2)
end

if strcmp(wavType, 'wav') || strcmp(wavType, 'flac')
    %Decimating wav files is easy
    %     [data,fs,nbits]=wavread([PARAMS.inpath,PARAMS.infile],'native');
    try 
        [data,fs] = audioread([PARAMS.inpath,PARAMS.infile], 'native');
    catch ME
        disp_msg(ME.message)
        dmsg = sprintf('Is %s a real wave file?', ...
            fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:)));
        disp_msg(dmsg);
        return
    end
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
        %         wavwrite(int16(odata), new_fs, nbits, [PARAMS.outpath,PARAMS.outfile]);
        audiowrite([PARAMS.outpath,PARAMS.outfile],int16(odata),new_fs,'BitsPerSample',nbits);
    elseif nbits == 24
        %         wavwrite(int32(odata), new_fs, nbits, [PARAMS.outpath,PARAMS.outfile]);
        audiowrite([PARAMS.outpath,PARAMS.outfile],int32(odata),new_fs,'BitsPerSample',nbits);
    elseif nbits == 32
        %         wavwrite(int32(odata), new_fs, nbits, [PARAMS.outpath,PARAMS.outfile]);
        audiowrite([PARAMS.outpath,PARAMS.outfile],int32(odata),new_fs,'BitsPerSample',nbits);
    else
        disp_msg('Error: bit size not supported')
        disp_msg(['Nbits = ', num2str(nbits)])
        return
    end
    disp_msg('Done');
    return
end

fid = fopen([PARAMS.inpath,PARAMS.infile],'r');
fod = fopen([PARAMS.outpath,PARAMS.outfile],'a');   % open as append,
% don't need to fseek

% if PARAMS.nch == 1
%     nsamp = 15e6;       % number of samples to read for each decimation
%                         % also the number of samples in each hrp raw file
% elseif PARAMS.nch == 4
%     nsamp = 3.596e6;    % number of samples per channel to read for decimation
% else
%     disp_msg('Error : number of channels not 1 or 4')
%     disp_msg(['PARAMS.nch = ',num2str(PARAMS.nch)])
% end
%
% total_samples = PARAMS.xhd.dSubchunkSize / (PARAMS.samp.byte * PARAMS.nch);
%
% dnf = total_samples/nsamp; % number of decimations -- floating point
%
% dn = floor(dnf);            % integer number of decimations
% drem = dnf - dn;            % remainder (percentage) number of decimations
% if drem ~= 0
%     disp_msg(['remainder of decimated samples ', num2str(drem)])
% end
%
% if (drem > 0)               % most typical case
%     dn = dn + 1;
%     nsampLast = floor(nsamp * drem);
% elseif drem == 0
%     disp_msg('all decimations same size')
%     nsampLast = nsamp;
% elseif drem < 0
%     disp_msg('error -- not possible')
% end

dn = PARAMS.xhd.NumOfRawFiles;

disp_msg(['Number of decimations : ',num2str(dn)])

tic % start stopwatch timer
% main loop to read in data from xwav, decimate, then write out to new xwav
% file
precision = strcat('int',num2str(PARAMS.nBits));
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
        end
    case 'flac'
        % this never gets called because of continue after simple
        % decimation for wav and flac above.
    case 'x.wav'
        for di = 1:dn
            %             if di == dn
            %                 nsamp = nsampLast; % number of samples for last decimation
            %             end
            nsamp = PARAMS.xhd.byte_length(di) ./ (PARAMS.samp.byte * PARAMS.nch);
            if rem(nsamp,PARAMS.df) ~= 0
                nsamp = nsamp - rem(nsamp,PARAMS.df);
            end
            % jump over header and the number of decimations done so far...
            %             fseek(fid,PARAMS.xhd.byte_loc(1) +...
            %                 (di-1)*nsamp*PARAMS.nch*PARAMS.samp.byte,'bof');
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
        end
end
disp_msg('Done');
toc
fclose(fid);
fclose(fod);



