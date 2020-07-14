function XMLwritecalls (timestamps, score, dxml)

% Adapted from Shyam's BatchClassifyBlueCalls
% Updated to write score after start time
% smk 100713
import tethys.nilus.*; %JAXB Package
global PARAMS;

speciesID = 180528; %TSN for Blue Whales
% fullname=fopen(in_fid);
% [~,name,ext] = fileparts(fullname);
% input_file = strcat(name,ext);

% TODO make sure that this is the format expected when running
% rename some global variables for brevity
input_file = PARAMS.infile; % input xwav

% loop through each of the detections to write
for k = 1:length(timestamps)
    dvec = datevec(timestamps(k));
    fraction = num2str(dvec(6) - floor(dvec(6)));
    fraction = fraction(2:end);
    thisScore = score(k);
    start=dbSerialDateToISO8601(datenum(dvec));
    oed=Detection(start,speciesID); %XML detection object
    oed.addCall('B NE Pacific');
    oed.setInputFile(input_file);
    oed.parameters.setScore(java.lang.Double(thisScore));
    %oed.popParameters();
    dxml.addDetection(oed);
    fprintf(PARAMS.outfid, '%s%s\t%f\n', datestr(timestamps(k), 31), fraction, thisScore);
end

% if totalCalls > 0
%     % only include detections from the first half of the window to 
%     % account for sliding window and avoid double counting
%     saveList = timestamps(find(timestamps(:,1) <= PARAMS.tseg.sec/2), :);
%     savedCalls = size(saveList, 1);
%            
%     if savedCalls > 0
%         for m = 1:length(saveList)
%             %put detections into raw file bins and add offset
%             
% %             whichraw = ceil((saveList(m)+start_time)/75);
%            
%             RealSec(m) = start_time + saveList(m);          
%             
%             abstime = dateoffset + datenum([0 0 0 0 0 RealSec(m)])+ start_time;
%             
%             dvec = datevec(abstime(1));
%             fraction = num2str(dvec(6) - floor(dvec(6)));
%             fraction = fraction(2:end);
%             thisScore = score(m);
%             start=dbSerialDateToISO8601(datenum(dvec));
%             oed=Detection(start,speciesID); %XML detection object
%             oed.addCall('B NE Pacific');
%             oed.setInputFile(input_file);
%             oed.parameters.setScore(java.lang.Double(thisScore));
%             %oed.popParameters();
%             dxml.addDetection(oed);
%             fprintf(PARAMS.outfile, '%s%s\t%f\n', datestr(abstime(1), 31), fraction, thisScore);
%            
%         end
%         
%     end
end


