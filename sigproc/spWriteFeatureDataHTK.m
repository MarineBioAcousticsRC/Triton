function spWriteFeatureDataHTK(File, FramesByRow, FrameAdvanceMS, Kind)
% spWriteFeatureDataHTK(File, FramesByRow, FrameAdvanceMS, Kind)
% Write an HTK format data file. 
% Each row of FramesByRow is a feature vector
% Kind is any supported Parameter kind with qualifiers
% See Chapter 5 of the HTK Book for details.
% Supports HTK 3.3 and any backward compatible future version

    function encoding = SetField(encoding, field, value)
        % encoding = SetField(encoding, field, value)
        % Set value in appropriate field of encoding.  If value
        % is not present, assume 1.
        
        if nargin < 3
            value = 1;
        end
        
        if isstr(field)
            % field specified by name, find index
            field_str = field;
            field = strmatch(field_str, Fields);
            if isempty(field)
                error('Bad field name or qualifier %s', field_str)
            end
        end
        
        % Reset field
        encoding = bitand(encoding, bitcmp(BitMasks(field), 32));
        % Set to user specified value
        if nargin == 3
            % Take advantage of the only non flag value
            % being in the lowest bits, otherwise we need
            % to shift.
            encoding = bitor(encoding, bitshift(value, BitShifts(field)));
        else
            encoding = bitor(encoding, BitMasks(field));
        end
        
    end     % close off nested fn

    function err = error_str()
        KindsStr = sprintf('%s ', ParamKinds{:});
        FieldsStr = sprintf('_%s ', Fields{2:end});
        err = sprintf(...
            'HTK kind must be in \n[%s]\n with optional parameters %s\n', ...
            KindsStr, FieldsStr);
    end

error(nargchk(4,4,nargin))

% fields and corresponding bit masks
% must be in order from least significant to most significant bit
% must match enumerations in HTKLib/HParm.h
Fields = {'encoding', 'E', 'N', 'D', 'A', 'C', 'Z', 'K', 'O', 'V', 'T'};
FieldSize = [
    6   % encoding
    1   % E energy
    1   % N absolute energy supressed
    1   % D delta
    1   % A acceleration
    1   % C compressed
    1   % Z means subtraction
    1   % C CRC check
    1   % O (OH) MFCC 0
    1,  % V Has VQ index attached
    1   % T has delta-delta-delta index attached
    ];

ParamKinds = {
    'WAVEFORM',
    'LPC'
    'LPREFC'
    'LPCEPTRSA'
    'LPDELCEP'
    'IREFC'
    'MFCC'
    'FBANK'
    'MELSPEC'
    'USER'
    'DISCRETE'
    'ANON'
    };

% Number of bits each field must be shifted
BitShifts = cumsum(FieldSize);
BitShifts = [0; BitShifts(1:end-1)];
% Construct bit masks
BitMasks = bitshift(bitcmp(zeros(size(FieldSize)), FieldSize), BitShifts);
encoding = 0;

if isstruct(Kind)
  % Assume that we have an information structure similar to 
  % that provided by spReadFeatureDataHTK.
  for k=1:length(Fields)
    if isfield(Kind, Fields{k})
      switch Fields{k}
       case 'encoding'
        encoding = SetField(encoding, k, Kind.encoding)
       otherwise
        if info.Fields{k}
          encoding = SetField(encoding, k);
        end
      end
    end
  end
elseif isstr(Kind)
    

  % Parse out the user specification
  names = regexp(Kind, '^(?<Kind>[A-Za-z0-9]+)(?<Quals>_[A-Z])*$', 'names');  
  if isempty(names)
    error(error_str());
  else
    % search for parameter kind
    KindIdx = strmatch(names.Kind, ParamKinds, 'exact');
    if isempty(KindIdx)
      error(error_str())
    else
      encoding = SetField(encoding, 'encoding', KindIdx - 1);
    end
    
    if isfield(names, 'Quals')
      if isstr(names.Quals)
        for k=2:2:length(names.Quals)
          encoding = SetField(encoding, names.Quals(k));
        end
      end
    end
  end
end

spWriteHTK(File, FramesByRow, FrameAdvanceMS / 1000, encoding);

end     % close off main function
