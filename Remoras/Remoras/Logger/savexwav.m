function filename = savexwav(filename)

global PARAMS handles DATA

% todo:  We should perhaps verify that there's actually an audio
% plot displayed.  Old audio data is kept even when it is not displayed

% Verify that audio is available
if isempty(DATA) || isempty(PARAMS.plot.dnum)
    error('Triton:NoAudio', 'No Waveform')
end

% Set up to write header
[fdir, fname, ext] = fileparts(filename);
PARAMS.outpath = [fdir, filesep];
PARAMS.outfile = [fname, ext];

wrxwavhd(1)  % write xwav header into output file

% dump data to output file
% open output file
filename = [PARAMS.outfile];
fod = fopen([PARAMS.outpath,PARAMS.outfile],'a');
switch PARAMS.nBits
    case 16
        dtype = 'int16';
    case 32
        dtype = 'int32';
    otherwise
        error('Triton:Audio', ...
            '%d bit samples are not supported', PARAMS.nBits);
end
fwrite(fod,DATA,dtype);
fclose(fod);
   