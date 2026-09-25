function report = xwavdir2flac(indir, varargin)
%XWAVDIR2FLAC  Compress a folder of x.wav to x.flac.  (Kept for existing use.)
%
%   xwavdir2flac('E:\HARP\SiteA')                       % dry run
%   xwavdir2flac('E:\HARP\SiteA', 'go', true)
%
% **The name to use now is audiodir2flac**, which takes a destination folder as
% its second argument, handles plain .wav as well as .x.wav, mirrors the source
% structure, guards the destination's free space and writes a log. This wrapper
% stays so that anything already calling it keeps working.
%
% NOTE: this function lives in Extras/, which is not on the MATLAB path on a
% normal Triton install -- see check_path.m. audiodir2flac is in the base
% folder and is always available.
%
%   'go'            actually convert (default false, i.e. a dry run)
%   'keepXwav'      keep the originals (default true)
%   'outdir'        where to write; default alongside each source file
%   'recursive'     walk subfolders (default true)
%   'flac'          path to the flac tool
%   'skipExisting'  leave outputs that are already there (default true)
%
% See also AUDIODIR2FLAC, XWAV_CONVERT_DIR, AUDIO2FLAC.

p = inputParser;
addParameter(p,'go',false);
addParameter(p,'keepXwav',true);
addParameter(p,'outdir','');
addParameter(p,'recursive',true);
addParameter(p,'flac','');
addParameter(p,'skipExisting',true);
parse(p,varargin{:});
opt = p.Results;

outdir = opt.outdir;
if isempty(outdir); outdir = indir; end

% The old default was to skip anything already present without looking at it.
% 'verified' is safer -- it re-does an output that does not pass its check,
% which after an interrupted run is exactly the set worth redoing.
if opt.skipExisting; ow = 'verified'; else; ow = 'replace'; end

r = xwav_convert_dir(indir, outdir, ...
    'direction',  'compress', ...
    'go',         opt.go, ...
    'recursive',  opt.recursive, ...
    'keepInput',  opt.keepXwav, ...
    'overwrite',  ow, ...
    'flac',       opt.flac);

% Old callers expect these field names.
report = struct('converted',{{}}, 'failed',{{}}, 'skipped',{{}}, ...
                'bytesIn',r.bytesIn, 'bytesOut',r.bytesOut);
for k = 1:numel(r.plan.files)
    f = r.plan.files(k);
    if strcmp(f.status,'ready')
        report.converted{end+1} = f.dst; %#ok<AGROW>
    else
        report.failed{end+1} = struct('file',f.src,'why',f.why); %#ok<AGROW>
    end
end
end
