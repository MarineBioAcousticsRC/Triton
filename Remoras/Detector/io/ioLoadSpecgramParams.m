function result = ioLoadSpecgramParams(filename, handles)
% ioLoadSpecgramParams(filename, handles)
% Load stored spectrogram controls from filename into specified handle
% structure.  
% 
% Returns true on full or partial success, false on  catastrophic failure
% Error dialogs are provided
result = false; % Assume false until we actually change something

fid = fopen(filename,'r'); % open data file
if fid ~= -1    % opened
  % File should consist of triplets, one per line in the following
  % format:
  %     name            - name of the handle object in the handles structure
  %     property        - property to load
  %     value           - value to which the property should be set

  N = 0;
  Parameter = fgetl(fid);       % Priming read
  ErrorStr = [];

  while ischar(Parameter)
    % Loop through triplets
    
    Property = fgetl(fid);
    if ~ ischar(Property)
      ErrorStr = sprintf('Bad parameter file %s. %s %s', filename, ...
          'Expected handle property but reached end of file.', ErrorStr);
      break   % not worth trying any more
    end
    
    ValueStr = fgetl(fid);
    if ~ ischar(ValueStr)
      ErrorStr = sprintf('Bad parameter file %s.  %s', filename, ...
          'Expected handle value but reached end of file', ErrorStr);
      break   % not worth trying any more
    end
    
    N = N+1;
    switch Property
        case 'Value'
            Value = str2double(ValueStr);       % Property requires number
        otherwise
            Value = ValueStr;
    end
    try
        set(handles.(Parameter), Property, Value);
        result = true;
    catch
        event = sprintf('handle object %s, property %s=%s', ...
                        Parameter, Property, ValueStr);
        if N == 0
            ErrorStr = sprintf('Unable to set: [%s', event);
        else
            ErrorStr = sprintf('%s, %s', ErrorStr, event);
        end
    end
    
    Parameter = fgetl(fid);     % start next parameter
  end
    
  fclose(fid);

  if ~ isempty(ErrorStr)
    if result
      warndlg(sprintf(...
          'Unable to set parameters for some handles:  %s', ErrorStr));
    else
      errordlg(ErrorStr);
    end
  end
end
