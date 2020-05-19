function bp_Fin3PowerDetectDay_ST

% ripped from SpectAves.m that made 1 hr spectral averages from LTSA
% 110921 smw
% 130820as - modifying to use for fin whale 20 Hz power index calculation
% calculating average daily values for fin 20Hz acoustic pwr index
% 160209as - modified to work with OCNMS duty cycle; no need to manually
% enter duty cycle as it pulls time stamps from calculated LTSAs
% 
% run after loading full LTSA via Triton; make sure LTSA starts at start of
% raw file write so timing matches
% IMPORTANT: load appropriate transfer function for comparable power values!!
% also good idea to scroll back and forth to start of file; not sure why
global REMORA
global PARAMS

LinkTethys = REMORA.bp.settings.Tethys;

if LinkTethys == true
import tethys.nilus.*;
end

tic
%user defined variables:
userid =  REMORA.bp.settings.userid; %change to your username, usually firstinitial+lastname(jdoe)
version = '3.0';  %change to reflect version of this detector
%3.0 for version where time is not manually calculated but pulled from
%LTSA time stamps
%2.0 for power index where threshold is NaN; 
%1.0 for call level in 5s bins where threshold is real number
triton_version = PARAMS.ver; %change to reflect version of Triton
granularity = REMORA.bp.settings.granularity; %type of granularity, allowed: call, encounter, binned
binsize = REMORA.bp.settings.binsize;   %in minutes; this is one hour
call = '20Hz'; %string to describe calls of interest
callsubtype = '';

xml_dir = REMORA.bp.settings.outDir; %location of output XML, notice double backslash (java thing).
%xml_dir = 'E:\\General LF Data Analysis\\Fin 20Hz detector\\detector output\\'; %location of output XML, notice double backslash (java thing).
new_filename = dir(strcat(REMORA.bp.settings.inDir,'\*.ltsa'));
xml_filename = new_filename.name(1:strfind(new_filename.name,'.ltsa')-1);  %remove ltsa from filename
xml_out= strcat(xml_dir,'\',xml_filename,'_20finDPI.xml');  %unique identifier for daily power index
csv_out=strcat(xml_dir,'\',xml_filename,'_20finDPI.csv');

%opening LTSA file to be able to continue reading from it
if isempty(PARAMS.ltsa.inpath) || isempty(PARAMS.ltsa.infile)
    error('Load an LTSA file');
end
fid = fopen([PARAMS.ltsa.inpath,PARAMS.ltsa.infile],'r');
nbin = floor((PARAMS.ltsa.tseg.hr * 60 *60 ) / PARAMS.ltsa.tave);
skip = PARAMS.ltsa.byteloc(PARAMS.ltsa.plotStartRawIndex) + ....
    (PARAMS.ltsa.plotStartBin - 1) * PARAMS.ltsa.nf + ...%nbin;
    PARAMS.ltsa.nf * nbin;
fseek(fid,skip,-1);    % skip over header + other data read in first LTSA

ltsaplotstart = PARAMS.ltsa.plotStartRawIndex;
pwr = [];
firsttime = PARAMS.ltsa.dnumStart(ltsaplotstart);
%timeincr = datenum([0 0 0 0 0 5]);
k = 1;
timess = []; ScoreVal = []; ttime = []; totalpwer = []; dayVal = [];
pwr = PARAMS.ltsa.pwr;
%nbin = floor(PARAMS.ltsa.tseg.sec/PARAMS.ltsa.tave);
%pwr = fread(fid, [PARAMS.ltsa.nf, nbin],'int8');
stleng = size(pwr,2);

% %enter duty cycle for the deployment; if none enter 0s
% interval = 28+28/60;
% duration = 5;


%load appropriate transfer function to apply to data
tffilename = REMORA.bp.settings.tffile;
[tf1] = bp_load_TFfile(tffilename);

%apply the transfer function
for i=1:size(pwr,2)
    %pwr(:,i) = pwr(:,i)+tf1.';
    pwr(1:1001,i) = pwr(1:1001,i)+tf1.';
end

%Detector parameters
threshold = REMORA.bp.settings.thresh;
callfreq = REMORA.bp.settings.callfreq;
nfreq1 = REMORA.bp.settings.nfreq1;
nfreq2 = REMORA.bp.settings.nfreq2;
LTSAres_time = num2str(PARAMS.ltsa.tave); %time bin of LTSA
LTSAres_freq = num2str(PARAMS.ltsa.dfreq); %frequency bin of LTSA

if  LinkTethys == true
    %%XML STUFF%%
%Create Javabean
detections = Detections();
speciesID = 180527;%ITIS TSN for fin whales - balaenoptera physalus
%Grab datasource info from filename
filenm = PARAMS.ltsa.infile(1:(end-5));
project = REMORA.settings.project;
site = REMORA.settings.site;
deployment = REMORA.settings.deployment;

detections.setSite(project, site, deployment);%set datasource info to this
%userID
detections.setUserID(userid);
%Algorithm Information (e for element name, v for value)
%values must be STRINGS because matlab(or my coding skill) sucks with anything else..
ethresh = 'Threshold';
ecallfreq = 'CallFreq';
enfreq1 = 'NoiseFreq1';
enfreq2 = 'NoiseFreq2';
efile = 'FileName';
eres_time = 'LTSAres_time';
eres_freq = 'LTSAres_freq';
vcallfreq = num2str(callfreq);
vthresh = num2str(threshold);
vnfreq1 = num2str(nfreq1);
vnfreq2 = num2str(nfreq2);
vfile = PARAMS.ltsa.infile;
vres_time = LTSAres_time;
vres_freq = LTSAres_freq;

detections.setAlgorithm({'finDetector', version, 'Energy Detector'});
%any (even)number of arguments can be input for parameters, but make sure to
%wrap them in {   } because matlab is a dummy with java methods
detections.addAlgorithmParameters({ethresh,vthresh,ecallfreq,vcallfreq,...
    enfreq1,vnfreq1,enfreq2,vnfreq2,eres_time,vres_time,eres_freq,vres_freq}); 
%got rid of "efile,vfile," in line above to not include general filename
%define support software
detections.addSupportSoftware( {'Triton', triton_version,});

%set effort details (kind)
detections.addKind(speciesID,{granularity,call,callsubtype,binsize}); %once again, notice the {  }
end

%record start of effort
effort(1) = firsttime+datenum([2000 0 0 0 0 0]);
effStart = dbSerialDateToISO8601(effort(1));
tc = find(PARAMS.ltsa.dnumStart==firsttime);
newtime = effort(1);
ttime = newtime;
% plot length of 2 h seems to work well
while ~feof(fid)
    %calculate the SNR between freq in fin band and adjacent noise
    %(averaged from freq band above and below calls and assumed linear)
    pwrave = pwr(callfreq,:)-((pwr(nfreq1,:)+pwr(nfreq2,:))/2);   %Det3
    %find all times when the SNR is negative and fix to 0
    pwrave(pwrave<0)=0;
    totalpwer = [totalpwer pwrave];
    stepss = size(pwrave,2) * PARAMS.ltsa.tave;
    %create 75s averages to match time stamps
%     stepss = size(pwrave,2)/15;
%     newvec = reshape(pwrave,[15,size(pwrave,2)/15]);
%     newvec = mean(newvec,1);
%     totalpwer = [totalpwer newvec];
    
    % Assign time stamp to the chunk 
    newtime = newtime+datenum([0 0 0 0 0 stepss]);
    ttime = [ttime; newtime];
    
%assign time stamps to each 75s chunck
%     if (tc+stepss)<=size(PARAMS.ltsa.dnumStart,2) 
%         ttime = [ttime; PARAMS.ltsa.dnumStart(tc:tc+stepss-1)'];
%     else ttime = [ttime; PARAMS.ltsa.dnumStart(tc:end)'];
%     end
%     tc = tc+stepss;
    
    %when it goes into a new day, we average it all out and write out
    %detection
    ttimevec = datevec(ttime);
    %checking if we're in a new day
    if ttimevec(1,3)~=ttimevec(size(ttimevec,1),3)
        %if we are, average the power and add date stamp
        indx = find(ttimevec(:,3)==ttimevec(1,3));
        dailypwr = mean(totalpwer(1:indx(end)*nbin));
        ScoreVal = [ScoreVal dailypwr];
        timestamp = datenum(ttimevec(1,1),ttimevec(1,2),ttimevec(1,3));
        if ttimevec(1,1)<2000
        dayVal = [dayVal timestamp+datenum([2000 0 0 0 0 0])];
        else
            dayVal = [dayVal timestamp];
        end
        %need to save data that are not in that day
        newpwr = totalpwer((indx(end)*nbin)+1:end);
        newtime = ttime(indx(end)+1:end);
        ttime = []; totalpwer = []; pwrave= []; indx = []; pwr = []; newvec = [];
        totalpwer = newpwr;
        ttime = newtime;
        newpwr = [];
        %then write the detection
        if ttimevec(1,1) < 2000
        dtime = timestamp+datenum([2000 0 0 0 0 0]);
        else
            dtime = timestamp;
        end
        
        %check that the beginning of effort falls before the timestamp
        startISO = dbSerialDateToISO8601(dtime);
        if dtime<effort(1),
            startISO = effStart;
        end
        if LinkTethys == true
        oed = Detection(startISO,speciesID);
        score = dailypwr;
        oed.addCall(call);
        oed.setInputFile(PARAMS.ltsa.infile);
        oed.parameters.setScore(java.lang.Double(score));
        detections.addDetection(oed);
        end
       % dailypwrTot(k) = dailypwr;
       % datetimeTot(k) = startISO;
    end
    pwr = fread(fid,[PARAMS.ltsa.nf,nbin],'int8');   % read next chunk data
    %apply the transfer function
    if ~isempty(tffilename)
    for i=1:size(pwr,2)
        %pwr(:,i) = pwr(:,i)+tf1.';
        pwr(1:1001,i) = pwr(1:1001,i)+tf1.';
    end
    end
    k = k+1;
end

% %go through the last bit of data
% pwrave = pwr(callfreq,:)-((pwr(nfreq1,:)+pwr(nfreq2,:))/2);   %Det3
% pwrave(pwrave<0)=0;
% stepss = size(pwrave,2)/15;
% newvec = pwrave(1:15*floor(size(pwrave,2)/15));
% newvec = reshape(newvec,[15,floor(size(pwrave,2)/15)]);
% newvec = mean(newvec,1);
% totalpwer = [totalpwer newvec];
% %assign time stamps to remaining 75s chuncks
% ttime = [ttime; PARAMS.ltsa.dnumStart(tc:end)'];
% ttimevec = datevec(ttime);
% %checking if we're in a new day part of the way through
% if ttimevec(1,3)~=ttimevec(size(ttimevec,1),3)
%      %if we are, average the power and add date stamp
%      indx = find(ttimevec(:,3)==ttimevec(1,3));
%      dailypwr = mean(totalpwer(indx));
%      ScoreVal = [ScoreVal dailypwr];
%      timestamp = datenum(ttimevec(1,1),ttimevec(1,2),ttimevec(1,3));
%      dayVal = [dayVal timestamp+datenum([2000 0 0 0 0 0])];
%      %save data that are not in the old day but remain
%      newpwr = totalpwer(indx(end)+1:end);
%      newtime = ttime(indx(end)+1:end);
%      timess = []; ttime = []; totalpwer = []; pwrave= []; indx = [];
%      totalpwer = newpwr;
%      ttime = newtime;
%      %then write the detection
%      %includes dailypwr; timestamp+datenum([2000 0 0 0 0 0]);
%      dtime = timestamp+datenum([2000 0 0 0 0 0]);
%      startISO = dbSerialDateToISO8601(dtime);
%      oed = Detection(startISO,speciesID);
%      score = dailypwr;
%      oed.addCall(call);
%      oed.setInputFile(PARAMS.ltsa.infile);
%      oed.parameters.setScore(java.lang.Double(score));
%      oed.popParameters();
%      detections.addDetection(oed);
% end

dailypwr = mean(totalpwer);
ScoreVal = [ScoreVal dailypwr];
ttimevec = datevec(ttime);
timestamp = datenum(ttimevec(1,1),ttimevec(1,2),ttimevec(1,3));
if ttimevec(1,1)<2000
dayVal = [dayVal timestamp+datenum([2000 0 0 0 0 0])];
else
    dayVal = [dayVal timestamp];
end

%then write the detection
%includes dailypwr; timestamp+datenum([2000 0 0 0 0 0]);
if LinkTethys == true
    dtime = timestamp+datenum([2000 0 0 0 0 0]);
    startISO = dbSerialDateToISO8601(dtime);
    oed = Detection(startISO,speciesID);
    score = dailypwr;
    oed.addCall(call);
    oed.setInputFile(PARAMS.ltsa.infile);
    oed.parameters.setScore(java.lang.Double(score));

    detections.addDetection(oed);
end    


%index values represented by totalpwer I think, but maybe also by
%dailypwer, except that was only one value.
%record end of effort
effort(2) = PARAMS.ltsa.dnumStart(end);
if ttimevec(1,1)<2000
effort(2) = effort(2)+datenum([2000 0 0 0 0 0]);
end

%%Write csv%%
datetime = dbSerialDateToISO8601(dayVal);
Date = datetime';
DailySNR = ScoreVal';
dets = table(Date,DailySNR);
writetable(dets,csv_out);

%%Final XML stuff%%
%convert start/end effort times, set and output XML
%uses Marie's function dbSerialDatetoISO8601 --if you're getting errors
%here let me know and I can supply the function
effEnd = dbSerialDateToISO8601(effort(2));  

if LinkTethys == true
detections.setEffort(effStart,effEnd);
detections.marshal(xml_out);
end

datevec(effort)
t = toc;
disp(' ')
disp(['FinPowerDetect Execution time = ',num2str(t),' seconds'])

figure(100);
plot(dayVal,ScoreVal);
xlabel('Day');
ylabel('Fin acoustic power index');
end