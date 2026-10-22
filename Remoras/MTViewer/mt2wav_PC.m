%code to convert .mt files from Bprobes and Acousondes to .wav files for
%analysis in Triton

%mfm 2011-06-20, mfm 2011-06-28 mac version
%Jah added user interaction for in and out path

%--------------------------------------------------------------------------
clear var; 
close all;
fprintf('\n');
fprintf('Converting .MT files to .WAV files\n');
fprintf('\n');

%TAG TYPE -----------------------------------------------------------------
prompt1={'Enter tag type (1=Acousonde, 2=Bprobe)'};
inl = inputdlg(prompt1); flag = str2num(inl{1});

%DIRECTORY OF FILES TO PROCESS---------------------------------------------
% Open a dialog box to select a directory
start_path = uigetdir;
% Check if the user selected a directory
if start_path == 0
    disp('No directory selected. Exiting.');
    return;
else
    % Display the selected directory
    disp(['Selected directory: ', start_path]);
end
% Open a dialog box to select an output directory
output_path = uigetdir;

% Check if the user selected a directory
if output_path == 0
    disp('No directory selected. Exiting.');
    return;
else
    % Display the selected directory
    disp(['Selected output directory: ', output_path]);

    % Create the subdirectory "wav_files"
    wav_files_path = fullfile(output_path, 'wav_files');
    if ~exist(wav_files_path, 'dir')
        mkdir(wav_files_path);
        disp(['Subdirectory created: ', wav_files_path]);
    else
        disp(['Subdirectory already exists: ', wav_files_path]);
    end
end

% Continue with the rest of your code, using output_path and wav_files_path as needed
% ...

if flag==1 %Acousonde
     inpath = start_path;cd(inpath);D=dir;     % We only want the '*S*.MT' files for Sound VL
%    inpath = uigetdir(start_path);cd(inpath);D=dir('*.MT');
       % inpath = uigetdir(start_path);cd(inpath);D=dir('*H*.MT');  % JAH

elseif flag==2 %Bprobe
%     inpath = uigetdir(start_path);cd(inpath);D=dir('*_Sound_*.mt');
        inpath = start_path; cd(inpath); D=dir;
end

%PROCESS MT FILES (loop)---------------------------------------------------
for ii = 3:length(D)-1; %ii=1;
    [p,header,info] = MTRead_mfm([inpath '/' D(ii).name]);
    p2 = p; % convert units to uPa from mPa
    if ii == ceil(length(D)*.25)
        fprintf('.....');
    elseif ii == ceil(length(D)*.5)
        fprintf('.....');
    elseif ii == ceil(length(D)*.75)
        fprintf('.....');
    elseif ii == ceil(length(D)*.99)
        fprintf('.....');
        fprintf('\n');
    end
    
    %----------------------------------------------------------------------
    % select single file...
    %     boxTitle1 = ['Choose first MT file of series '];
     
    %     filterSpec = '*.MT';
    %     defaultName = 'C:\Users\Megan\Desktop\inProgress\chapt6_BlueWhaleCallingShipNoise\SEPT22_2010_Bm_A012\soundfiles\';
    %     [infile inpath]=uigetfile(filterSpec,boxTitle1,defaultName);
    %     [p,header,info] = MTRead([inpath infile]);
    %     p2 = p*1e3; % convert units to uPa from mPa
    %----------------------------------------------------------------------
    % HEADER INFORMATION
    yy =str2num(header.year); mm=str2num(header.month); dd=str2num(header.day);
    hh=str2num(header.hours); m=str2num(header.minutes); ss=str2num(header.seconds);
    strt = datenum(yy, mm, dd, hh, m, ss);
    strt_string=datestr(strt,'yymmdd-HHMMSS');
    n=info.srate;
    msamp = (length(p2)/n)/60;
    %--------------------------------------------------------------------------
%     figure(1)% data check
%     plot(p2);ylabel('uPa units');xlabel(datestr(strt))
    %--------------------------------------------------------------------------
    %write out wavfiles
    pout = int32(p2);
    max(p2);min(p2);
%     
    if flag==1
        %outfileA =(D(ii).name(1:8));
        outfileA =[strt_string '_' (D(ii).name(1:8)),'.wav'];
        %         wavwrite(pout,n,32,outfileA)
        outfile = fullfile(output_path,outfileA);
        audiowrite(outfile,pout,int64(n),'BitsPerSample',32)

    elseif flag==2
        outfileB =(D(ii).name(1:8));
%         outfileB =(D(1).name(1:22));
%         wavwrite(pout,n,32,outfileB)
         outfile = fullfile(output_path,[outfileB,pou,'.wav']);
         audiowrite(outfile,pout,int64(n),'BitsPerSample',32)

    end
    
    outdat = char(datestr(strt,'mm/DD/YYYY HH:MM:ss'));
    if flag == 1
        fprintf('%s %s \n',outdat, outfileA);
    elseif flag==2
        fprintf('%s %s \n',outdat, outfileB);
    end
    % just write it to the screen- and copy to txt
    % fprintf(fid, [outdat,' ', outfile, '%\n']); %matlab is too stupid to
    % creat a newline...ugh!!
    clear p pout p2 header info outfile outdate
    
fprintf('\n');
fprintf('Finished converting .MT files to .WAV files\n');
% fprintf('Location of .WAV files: %s\n',start_path);
fprintf('Location of .WAV files: %s\n',inpath); %VL 
fprintf('\n');
end

%READ WAV FILE-------------------------------------------------------------
% DW=dir('*.wav');
% [mm dd] = wavfinfo(fullfile(PARAMS.ltsa.indir,PARAMS.ltsa.fname(k,:));
% [mm dd] = wavfinfo(fullfile(inpath,DW))

% DIRECTORIES files pulled from:
% ONR_ShipNoise
% cd ('C:\Users\Megan\Desktop\inProgress\chapt6_BlueWhaleCallingShipNoise\SEPT22_2010_Bm_A012\soundfiles\');
% inpath='C:\Users\Megan\Desktop\inProgress\chapt6_BlueWhaleCallingShipNoise\SEPT22_2010_Bm_A012\soundfiles\';
% cd ('C:\Users\Megan\Desktop\inProgress\chapt6_BlueWhaleCallingShipNoise\BmShip_20101013_A012\soundfiles\');
% inpath='C:\Users\Megan\Desktop\inProgress\chapt6_BlueWhaleCallingShipNoise\BmShip_20101013_A012\soundfiles\';
% cd ('C:\Users\Megan\Desktop\inProgress\chapt6_BlueWhaleCallingShipNoise\BmShip_20101012_A012\soundfiles\');
% inpath='C:\Users\Megan\Desktop\inProgress\chapt6_BlueWhaleCallingShipNoise\BmShip_20101012_A012\soundfiles\';
% cd ('C:\Users\Megan\Desktop\inProgress\chapt6_BlueWhaleCallingShipNoise\SB_20090805_007_rosco\soundfiles\');
% inpath='C:\Users\Megan\Desktop\inProgress\chapt6_BlueWhaleCallingShipNoise\SB_20090805_007_rosco\soundfiles\';
% cd ('C:\Users\Megan\Desktop\inProgress\chapt7_BlueWhaleBehaviorShipsTAG\analysis\BRS_Bprobes\AUG23_2010_Bm_B019\BRS_AUG23_2010_Bm_JOIN\LB_Sound_2010_08231350\all\')
% inpath='C:\Users\Megan\Desktop\inProgress\chapt7_BlueWhaleBehaviorShipsTAG\analysis\BRS_Bprobes\AUG23_2010_Bm_B019\BRS_AUG23_2010_Bm_JOIN\LB_Sound_2010_08231350\all\'
% cd ('C:\Users\Megan\Desktop\inProgress\chapt7_BlueWhaleBehaviorShipsTAG\analysis\CloseApproach\SB_20080814_007_sneakers\soundfiles\')
% inpath='C:\Users\Megan\Desktop\inProgress\chapt7_BlueWhaleBehaviorShipsTAG\analysis\CloseApproach\SB_20080814_007_sneakers\soundfiles\'
% cd ('C:\Users\Megan\Desktop\inProgress\chapt7_BlueWhaleBehaviorShipsTAG\analysis\CloseApproach\SBC_20090916_025all_emma\soundfiles\')
% inpath = 'C:\Users\Megan\Desktop\inProgress\chapt7_BlueWhaleBehaviorShipsTAG\analysis\CloseApproach\SBC_20090916_025all_emma\soundfiles\'
% cd ('C:\Users\Megan\Desktop\inProgress\chapt7_BlueWhaleBehaviorShipsTAG\analysis\CloseApproach\SB_20090804_007_oliver\soundfiles\')
% inpath='C:\Users\Megan\Desktop\inProgress\chapt7_BlueWhaleBehaviorShipsTAG\analysis\CloseApproach\SB_20090804_007_oliver\soundfiles\'

% OlesonThesis
% cd ('C:\Users\Megan\Desktop\inProgress\chapt7_BlueWhaleBehaviorShipsTAG\analysis\CloseApproach\SBC_20090916_025all_emma\soundfiles\')
% inpath = 'C:\Users\Megan\Desktop\inProgress\chapt7_BlueWhaleBehaviorShipsTAG\analysis\CloseApproach\SBC_20090916_025all_emma\soundfiles\'

