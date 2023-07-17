function batchdetect(detext, CorpusBase)
% batchdetect(detext, CorpusBase)
% Run detections on a set of files in directory CorpusBase

if nargin < 1 || ~ ischar(detext)
    error('Must supply extension for detection files')
elseif detext(1) ~= '.'
        detext = ['.', detext];
end

if nargin < 2
    system = getenv('COMPUTERNAME');  % Windows only
    switch system
        case {'CAPENSIS', 'SPINNER', 'STENELLA'}
            CorpusBase = 'c:\Users\corpora\Paris-ASA\';
        case 'IRRAWADDY'
            CorpusBase = 'd:\home\bioacoustics\Paris-ASA\';
        otherwise
            error('unknown system');
    end
end

% make sure trailing file seperator on the CorpusBase
if CorpusBase(end) ~= filesep && CorpusBase(end) ~= '/'
    CorpusBase(end+1) = '\';
end

start_t = tic;

% find files for which we have ground truth
name = 'other';
switch name
    case 'dclmmpa2011'
        audio = {
            'bottlenose/palmyra092007FS192-070924-205305.wav'
            'bottlenose/palmyra092007FS192-070924-205730.wav'
            'bottlenose/Qx-Tt-SCI0608-N1-060814-121518.wav'
            'spinner/palmyra092007FS192-070927-224737.wav'
            'spinner/palmyra092007FS192-071011-232000.wav'
            'spinner/palmyra102006-061103-213127_4.wav'
            'melon-headed/palmyra092007FS192-070925-023000.wav'
            'melon-headed/palmyra092007FS192-071004-032342.wav'
            'melon-headed/palmyra102006-061020-204327_4.wav'
            'common/QX-Dc-FLIP0610-VLA-061015-165000.wav'
            'common/Qx-Dc-SC03-TAT09-060516-171606.wav'
            'common/Qx-Dc-CC0411-TAT11-CH2-041114-154040-s.wav'
            'common/Qx-Dd-SCI0608-N1-060815-100318.wav'
            'common/Qx-Dd-SCI0608-Ziph-060817-100219.wav'
            'common/Qx-Dd-SCI0608-Ziph-060817-125009.wav'
            };
        detections = strrep(audio, '.wav', detext);
        basedir = CorpusBase;
    case 'bhavesh'
        bhavesh = bhavesh_corpus();
        audio = bhavesh.gtfiles(:,1);
        gtfiles = strrep(audio, '.wav', '.bin');
      detections = strrep(audio, '.wav', detext);
      basedir = CorpusBase;
    otherwise
      [gtfiles, gtbasename] = utFindFiles({'*.bin'}, {CorpusBase}, true);
      audio = strrep(gtfiles, '.bin', '.wav');
      detections = strrep(gtfiles, CorpusBase, '');  % strip base prefix
      detections = strrep(detections, '.bin', detext);
      basedir = '';
end

N = length(audio);
for idx=1:N
    fprintf('Processing %d/%d %s to\n\t%s\n', idx, N, audio{idx}, detections{idx});
    d = dtTonalsTracking(fullfile(basedir, audio{idx}), 0, Inf, 'Framing', [2 8], 'Noise', {'median', [3 3], 3});
    % Create subdirectory if it does not exist
    [dname, fname] = fileparts(detections{idx});
    if ~ exist(dname, 'dir')
        mkdir(dname);
    end
    dtTonalsSave(detections{idx}, d);
    
    fprintf('Elapsed time since start:  %s\n', sectohhmmss(toc(start_t)));
    
end

