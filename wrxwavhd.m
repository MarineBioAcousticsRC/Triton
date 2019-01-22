function wrxwavhd(oftype)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% wrxwavhd.m
%
% write xwav header
% Parameters:
%         oftype - number representing what file header you are writing
%               1 == save window plotted data
%               2 == decimate whole xwav file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS DATA

save = PARAMS.nch;
% if making xwav from window plotted data
new_xhd = []; % temporary varible for to hold the header info
switch oftype
    % Saving plotted data
    case 1
        num_samples = length( DATA(:,PARAMS.ch) );
        data_bytes  = num_samples * 2; % 16 bits (2 bytes) per sample. Num bytes in
        %     rf_byte_length = PARAMS.xhd.byte_length( 1 ); % we're trusting they stay
        % consistent in xhd
        rf_byte_length = PARAMS.tseg.samp * PARAMS.samp.byte;
        num_rf = ceil( data_bytes / rf_byte_length );
        header_size = (8+4) + (8+16) + 64 + (32 * num_rf) + 8;
        rf_write_length = rf_byte_length / ( 512 - 12 ); % sector - 12 bytes of timing
        % initilize the header varibles
        new_xhd.time = inf * ones( num_rf , 7 );
        new_xhd.gain = PARAMS.xhd.gain( 1, num_rf ) * ones( 1, num_rf ); % they stat the same, could be wrong
        new_xhd.byte_loc = inf * ones( 1, num_rf );
        new_xhd.sample_rate  = PARAMS.xhd.sample_rate( 1, num_rf ) * ones( 1, num_rf ); % assume
        new_xhd.write_length = inf * ones( 1, num_rf );
        rf_secs = rf_byte_length / ( PARAMS.fs * 2 );% 2 bytes/samples * samples/sec  = bytes/sec
        %initilize the header varibles
        new_datevec = datevec( PARAMS.plot.dnum ); % initial time
        nsec = floor( new_datevec(6) );
        nticks = ( new_datevec(6) - nsec ) * 1000;
        %set for the first raw file
        new_xhd.time( 1, : ) = [ new_datevec(1:5) nsec nticks ];
        new_xhd.byte_loc( 1 ) = header_size;% Pad for header and dir listings
        new_xhd.byte_length( 1 ) = rf_byte_length;
        new_xhd.write_length( 1 ) = rf_write_length;
        %nothing special for anything not the first or last raw file
        if num_rf ~= 1
            for rf = 2:num_rf-1
                new_xhd.time( rf,: )      = [datevec(datenum([0 0 0 0 0 rf_secs]) + datenum(new_xhd.time(rf-1,1:6))) 0 ];
                new_xhd.write_length( rf )= rf_write_length;
                new_xhd.byte_loc( rf )    = new_xhd.byte_loc(rf-1) + rf_byte_length;
                new_xhd.byte_length( rf ) = rf_byte_length; %assuming it stays the same
            end
            % do the last raw file
            new_xhd.time( num_rf, : ) = [datevec(datenum([0 0 0 0 0 rf_secs]) + datenum(new_xhd.time(num_rf-1,1:6))) 0 ];
            new_xhd.byte_loc( num_rf ) = new_xhd.byte_loc(num_rf-1) + rf_byte_length;
            new_xhd.byte_length( num_rf ) = data_bytes - (new_xhd.byte_loc(num_rf) - header_size);
            new_xhd.write_length( num_rf ) = new_xhd.byte_length(num_rf) / (512-12);
        end
        % calculate last write length from here whatever other stuffs you need
        new_xhd.nsubchunksize = sum( new_xhd.byte_length(:) ) + ( header_size - 8 ); % header - 8 bytes
        new_xhd.dsubchunksize = sum( new_xhd.byte_length(:) );
        % Making an xwav
    case 2
        num_rf = PARAMS.xhd.NumOfRawFiles;
        % little risky, but give it a try:
        new_xhd.ByteRate = PARAMS.xhd.ByteRate ./ PARAMS.df;
        new_xhd.byte_length = PARAMS.xhd.byte_length ./ PARAMS.df;
        for rf = 1:num_rf
            if rem(new_xhd.byte_length(rf),PARAMS.samp.byte)
                new_xhd.byte_length(rf) = new_xhd.byte_length(rf) - 1;
            end
        end
        new_xhd.sample_rate = PARAMS.xhd.sample_rate ./ PARAMS.df;% new sample rate
        new_xhd.write_length = PARAMS.xhd.write_length ./ PARAMS.df;
        
        header_size = (8+4) + (8+16) + 64 + (32 * num_rf) + 8;
        new_xhd.nsubchunksize = sum( new_xhd.byte_length(:) ) + ( header_size - 8 ); % header - 8 bytes
        new_xhd.dsubchunksize = sum( new_xhd.byte_length(:) );
        new_xhd.time = inf * ones( num_rf , 7 ); % preinitialize for speed
        new_xhd.time =  [PARAMS.xhd.year(:) PARAMS.xhd.month(:) PARAMS.xhd.day(:)...
            PARAMS.xhd.hour(:) PARAMS.xhd.minute(:) PARAMS.xhd.secs(:)...
            PARAMS.xhd.ticks(:)];
        new_xhd.byte_loc( 1 ) = header_size;% Pad for header and dir listings
        for rf = 2:num_rf
            new_xhd.byte_loc( rf ) = new_xhd.byte_loc(rf-1) + new_xhd.byte_length(rf-1);
        end
        new_xhd.gain = PARAMS.xhd.gain( 1, num_rf ) * ones( 1, num_rf ); % they stat the same, could be wrong
        
        % Making a wav
    case 3
        num_rf = PARAMS.xhd.NumOfRawFiles;
end

newfs = PARAMS.fs/PARAMS.df;
% wav file header parameters
% RIFF Header stuff:
if oftype ~= 3
    harpsize = num_rf * 32 + 64 - 8;% length of the harp chunk
end
% Format Chunk stuff:
% fsize = PARAMS.xhd.fSubchunkSize;  % format chunk size
% fcode = PARAMS.xhd.AudioFormat;
fsize = 16;  % format chunk size
if PARAMS.nBits == 16 || PARAMS.nBits == 24
    fcode = 1;   % compression code (PCM = 1)
elseif PARAMS.nBits == 32
    fcode = 3;   % compression code (PCM = 3) for 32 bit
end
PARAMS.xhd.BlockAlign = PARAMS.nch * PARAMS.nBits/8; % byte for one sample with all channels
% open output file
fod = fopen( fullfile( PARAMS.outpath, PARAMS.outfile ), 'w' );

% write xwav file header
% RIFF file header                  % length = 12 bytes
fprintf( fod, '%c' , 'R' );
fprintf( fod, '%c' , 'I' );
fprintf( fod, '%c' , 'F' );
fprintf( fod, '%c' , 'F' );                      % byte 4
fwrite( fod, new_xhd.nsubchunksize, 'uint32' );               % ChunkSize
fprintf( fod, '%c', 'W' );
fprintf( fod, '%c', 'A' );
fprintf( fod, '%c', 'V' );
fprintf( fod, '%c', 'E' );

% Format information
fprintf( fod, '%c', 'f' );
fprintf( fod, '%c', 'm' );
fprintf( fod, '%c', 't' );
fprintf( fod, '%c', ' ' );                      % byte 16
fwrite( fod, fsize, 'uint32' );
fwrite( fod, fcode, 'uint16' );
fwrite( fod, PARAMS.nch, 'uint16' );         % only one channel of data shown in window this is wrong
fwrite( fod, newfs, 'uint32' );
fwrite( fod, newfs*PARAMS.xhd.BlockAlign, 'uint32' );   % ByteRate
fwrite( fod, PARAMS.xhd.BlockAlign, 'uint16' );
fwrite( fod, PARAMS.nBits, 'uint16' );                  % byte 35 & 36

if oftype ~= 3
    % "harp" chunk (64 bytes long)
    fprintf( fod, '%c', 'h' );
    fprintf( fod, '%c', 'a' );
    fprintf( fod, '%c', 'r' );
    fprintf( fod, '%c', 'p' );
    fwrite( fod, harpsize, 'uint32');
    fwrite( fod, PARAMS.xhd.WavVersionNumber , 'uchar' );
    fprintf( fod, '%c', PARAMS.xhd.FirmwareVersionNumber );  % 10 char
    fprintf( fod, '%c', PARAMS.xhd.InstrumentID );            % 4 char
    fprintf( fod, '%c', PARAMS.xhd.SiteName );                % 4 char
    fprintf( fod, '%c', PARAMS.xhd.ExperimentName );          % 8 char
    fwrite( fod, PARAMS.xhd.DiskSequenceNumber, 'uchar' );
    fprintf( fod, '%c', PARAMS.xhd.DiskSerialNumber );        % 8 char
    
    fwrite( fod, num_rf, 'uint16' );
    fwrite( fod, PARAMS.xhd.Longitude, 'int32' );
    fwrite( fod, PARAMS.xhd.Latitude, 'int32' );
    fwrite( fod, PARAMS.xhd.Depth, 'int16' );
    fwrite( fod, 0, 'uchar' );   % padding
    fwrite( fod, 0, 'uchar' );
    fwrite( fod, 0, 'uchar' );
    fwrite( fod, 0, 'uchar' );
    fwrite( fod, 0, 'uchar' );
    fwrite( fod, 0, 'uchar' );
    fwrite( fod, 0, 'uchar' );
    fwrite( fod, 0, 'uchar' );                        % byte 100
    for k = 1:num_rf
        fwrite( fod, new_xhd.time( k, 1 ), 'uchar' );
        fwrite( fod, new_xhd.time( k, 2 ), 'uchar' );
        fwrite( fod, new_xhd.time( k, 3 ), 'uchar' );
        fwrite( fod, new_xhd.time( k, 4 ), 'uchar' );
        fwrite( fod, new_xhd.time( k, 5 ), 'uchar' );
        fwrite( fod, new_xhd.time( k, 6 ), 'uchar' );
        fwrite( fod, new_xhd.time( k, 7 ), 'uint16' );
        fwrite( fod, new_xhd.byte_loc( k ), 'uint32' );
        fwrite( fod, new_xhd.byte_length( k ), 'uint32' );
        fwrite( fod, new_xhd.write_length( k ), 'uint32' );
        fwrite( fod, new_xhd.sample_rate( k ), 'uint32' );
        fwrite( fod, new_xhd.gain( k ), 'uint8' );
        fwrite( fod, 0, 'uchar' ); % padding
        fwrite( fod, 0, 'uchar' );
        fwrite( fod, 0, 'uchar' );
        fwrite( fod, 0, 'uchar' );
        fwrite( fod, 0, 'uchar' );
        fwrite( fod, 0, 'uchar' );
        fwrite( fod, 0, 'uchar' );
    end
end
% Data area -- variable length
fprintf( fod, '%c', 'd' );
fprintf( fod, '%c', 'a' );
fprintf( fod, '%c', 't' );
fprintf( fod, '%c', 'a' );           % data subchunk
fwrite( fod, new_xhd.dsubchunksize, 'uint32' ); % Data SubChunkSize

fclose( fod );
disp_msg( ['done writing header for ', PARAMS.outpath, PARAMS.outfile] )