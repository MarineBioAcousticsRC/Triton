function name = xwav_outname(inFile, kind, direction)
%XWAV_OUTNAME  What the converted file should be called.
%
%   name = xwav_outname('foo.wav', 'xwav', 'compress')   ->  'foo.x.flac'
%
% The name comes from what the file IS -- `kind`, decided from its bytes by
% audio_file_kind -- and not from what it happens to be called. A `.wav`
% carrying a harp chunk is an xwav whatever someone renamed it to, and it must
% come out as a `.x.flac`; sending it down the plain path would throw the
% raw-file directory and the deployment times away.
%
% Whatever extension the input has is stripped and the right one added, so a
% double extension can never accumulate.
%
% Lives in its own file because both the planner and the converter need it, and
% they must not be able to disagree about where a file is going.
%
% See also AUDIO_FILE_KIND, XWAV_CONVERT, XWAV_CONVERT_PLAN.

[~, n, e] = fileparts(inFile);
base = regexprep([n e], '\.(x\.wav|x\.flac|wav|flac)$', '', 'ignorecase');

switch [kind '_' direction]
    case 'xwav_compress';  name = [base '.x.flac'];
    case 'wav_compress';   name = [base '.flac'];
    case 'xflac_expand';   name = [base '.x.wav'];
    case 'flac_expand';    name = [base '.wav'];
    otherwise;             name = [base e];
end
end
