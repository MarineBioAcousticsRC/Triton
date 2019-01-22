function output_txt = datatip_tfnode(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

timefreq = get(event_obj,'Position');
if timefreq(2) < 5000
    output_txt{1} = sprintf('%.3f s X %.3f kHz', timefreq(1), timefreq(2));
else
    output_txt{1} = sprintf('%.3f s X %.1f kHz', timefreq(1), timefreq(2));
end
    



% grab associated object and its properties
target = get(event_obj, 'Target');
properties = get(target);

if isfield(properties, 'CData')
    % index in graphics obj (only partially documented)
    tfidx = get(event_obj, 'DataIndex');   % time x frequency indiceif length(tfidx) > 1
    % clicked on image
    
    % colormap access code derived from Mathworks
    % default_getDatatipText.m
    
    tidx = tfidx(1);
    fidx = tfidx(2);
    colordata = get(target, 'CData');
    raw_cdata_value = colordata(fidx, tidx);
    % Non-double types are 0 based
    if isa(raw_cdata_value,'double')
        cdata_value = raw_cdata_value;
    elseif isa(raw_cdata_value,'logical')
        cdata_value = raw_cdata_value;
    else
        cdata_value = double(raw_cdata_value) + 1;
    end
    userdata = get(target, 'UserData');
    raw_dB = userdata.snr_dB(fidx, tidx);
    output_txt{end+1} = sprintf('actual %.1f dB', raw_dB);
    output_txt{end+1} = sprintf('effective %.1f dB', cdata_value);
end
