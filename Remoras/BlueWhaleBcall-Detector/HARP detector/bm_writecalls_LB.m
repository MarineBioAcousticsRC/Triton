function bm_writecalls_LB(timestamps, score, ~)
% Adapted from Shyam's BatchClassifyBlueCalls
% Updated to write score after start time
% smk 100713

% Adapted from XMLwritecalls
% Modified to resolve issues reading xwav files with Tethys 2.5 update
% lb 030221

import nilus.*; % make nilus classes accessible
% import java.lang.Double.*;
global PARAMS detections helper detection marshaller

input_file = PARAMS.infile; % input xwav

OnEffort = detections.getOnEffort();
DetectionList = OnEffort.getDetection();

% loop through each of the detections to write
for k = 1:length(timestamps)
    dvec = datevec(timestamps(k));
    fraction = num2str(dvec(6) - floor(dvec(6)));
    fraction = fraction(2:end);
    thisScore = score(k);
    start = dbSerialDateToISO8601(datenum(dvec));
    
    detection = Detection();
    detection.setStart(helper.timestamp(start));

    % speciesID
    speciesID = 180528; %TSN for Blue Whales
    species_int = helper.toXsInteger(speciesID);
    speciestype = SpeciesIDType();
    speciestype.setValue(species_int);
    detection.setSpeciesID(speciestype);
    
    % call
    helper.createElement(detection, 'Call')
    callList = detection.getCall();
    acall = javaObject('nilus.Detection$Call');
    acall.setValue('B NE Pacific');
    callList.add(acall);
    
    % set parameters
    helper.createElement(detection, 'Parameters');
    DetectionParameter = detection.getParameters();
    DetectionParameter.setReceivedLevelDB(helper.toXsDouble(thisScore));
    
    detection.setInputFile(input_file);
    DetectionList.add(detection);
    
    fprintf(PARAMS.outfid, '%s%s\t%f\n', datestr(timestamps(k), 31), fraction, thisScore);
    
    marshaller.marshal(detection);
end
end