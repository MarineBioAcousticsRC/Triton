function [data, info] = spReadFeatureDataHTK(name);
% [data, info] = readhtkdata(name)
% Read HTK format feature data
% data - feature column vectors
% info - data description
%   .E - the last feature in the vector is energy
%   .D - delta coefficients are present.  
%   .A - accceleration coefficients (delta delta) are present. 
%   .C - data was saved in compressed mode (ratio of ints)
%   .Z - data has had cepstral means subtracted.  
%   .K - CRC check was present.  
%   .O - (letter oh, not zero)  Energy (zero'th coefficient) is present
%        HTK saves energy as the last row.
%
% CAVEATS:  CRC check is currently skipped, even if it is present
%
% Returns a set of column vectors containing HTK feature data.
% data(:,k) is the k'th feature vector.
%
% If the optional info output is included, a structure providing
% meta-information about the feature set is returned.
% Fields in info:
%  .Vectors - Number of vectors
%  .Dim - Dimensionality of vectors.
%  .CepstralSpacingMS - Frame advance in MS
%  .BytesPerVec - How many bytes per vector is used when stored on media
%       This may differ from the amount used when read into memory.
%  .coding - Type of feature file as per HTK
%  The following bit fields indicate the presence (non-zero) or absence
%  of features or processing.
%  .E - energy
%  .D - delta 
%  .A - acceleration
%  .C - feature file was compressed
%  .Z - cepstral means subtraction has been applied
%  .K - CRC check (CRC checking is not supported by this subroutine,
%       but it will read data with CRC coding)
%  .O - MFCC 0 is present
%
% Copyright 2002, Trausti Kristjansson (originally called readhtkdata)
% Modifications:
%     08/2004 Marie Roch
%     - Changed integer*4 to uint32 to prevent large ints from being
%       interpreted as negative numbers 
%     - Changed to open file using network ordering as HTK now stores
%       in network order by default.
%     - Reworked bit field manipulation and added information fields
%     01/2006 Marie Roch
%     - added coding string, similar to Mike Brookes voicebox code.
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
% =================================================================

SupressWarning = 1;

[fid,message] = fopen(name,'r', 'ieee-be');
if fid == -1
  error('Unable to read %s: %s', name, message)
else
  % Read HTK header
  info.Vectors = fread(fid,1,'int32');         % number of vectors
  advance100Ns = fread(fid,1,'int32');         % sample period in 100's ns
  info.CepstralSpacingMS = advance100Ns / 1e4;  % convert 100's ns to ms
  info.BytesPerVec = fread (fid,1,'uint16');    % # bytes per vector/sample

  paramkind = fread(fid,1,'uint16');    % bit fields

  % Note information on file contents/coding
  % In HTK chapter 5 as of HTK Book v. 3.3, Table 5.2, p. 78
  info.coding = bitand(paramkind, 2^6-1);    % specified in low order bits
  codings = {'WAVEFORM' 'LPC' 'LPREFC' 'LPCEPSTRA' 'LPDELCEP' ...
             'IREFC' 'MFCC' 'FBANK' 'MELSPEC' 'USER' 'DISCRETE' ...
             'PLP' 'ANON' 'Unrecognized coding'};
  info.coding_str = codings{min(length(codings), info.coding+1)};
  info.E = 1 & bitand(paramkind, sscanf('000200', '%o'));  % energy
  info.D = 1 & bitand(paramkind, sscanf('000400', '%o'));  % delta
  info.A = 1 & bitand(paramkind, sscanf('001000', '%o'));  % acceleration
  info.C = 1 & bitand(paramkind, sscanf('002000', '%o'));  % compressed
  info.Z = 1 & bitand(paramkind, sscanf('004000', '%o'));  % means subtraction
  info.K = 1 & bitand(paramkind, sscanf('010000', '%o'));  % CRC check
  info.O = 1 & bitand(paramkind, sscanf('020000', '%o'));  % MFCC 0
  
  if info.K & ~ SupressWarning
    warning('Skipping cyclic redundancy check.');
  end
  
  if info.C
    % compressed data

    % Unclear as to why this is the case, but we see this done
    % in HParm.c function OpenParmChannel, line 3554 of HTK 3.2.1.
    % It looks like they are including the space used for the A/B
    % vectors in the vector specifcation as each of the two vectors
    % takes up twice as much memory as a single vector.
    info.Vectors = info.Vectors - 4;
    
    info.Dim = info.BytesPerVec / 2;
    info.Compression.A = fread(fid, info.Dim, 'float32');
    info.Compression.B = fread(fid, info.Dim, 'float32');
    [data,n] = fread(fid, [info.Dim,  info.Vectors], 'int16');
    for i = 1:info.Dim
      data(i,:) = (data(i,:) + info.Compression.B(i)) ...
          ./ info.Compression.A(i);
    end

  else
    info.Dim = info.BytesPerVec / 4;
    [data,A] = fread(fid,[info.Dim, info.Vectors],'float32');
  end
  
  fclose(fid);                 
end;

