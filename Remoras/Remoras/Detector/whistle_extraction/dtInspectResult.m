function dtInspectResult(DetectionFile, CorpusBase, varargin)
% dtInspectResult(DetectionFile, CorpusBase, OptionalArgs)
% Assuming that the current directory is the root of a set of detections,
% show the detections and spectrogram for the specified DetectionFile.
%
% An optional CorpusBase specifies where the corpus files are kept.
% Omitting CorpusBase or passing in [] will result in a default root
% directory being selected.
%
% Any additional arguments will be passed as optional arguments
% to dtPlotUIGroundTruth.

AudioExts = {'.wav', '.x.wav'};  % Valid audio extensions
if nargin < 2 | isempty(CorpusBase)
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

[Dir, Basename, ext] = fileparts(DetectionFile);

% construct filename

found = false;
idx = 1;
while ~ found & idx <= length(AudioExts)
    audio = fullfile(CorpusBase, Dir, [Basename, AudioExts{idx}]);
    if exist(audio, 'file')
        found = 1;
    else
        idx = idx + 1;
    end
end

if found
    % retrieve detections
    detections = dtTonalsLoad(DetectionFile);
    dtPlotUIGroundtruth(audio, detections, 0, Inf, varargin{:});
else
    error('Unable to find audio file corresponding to %s', DetectionFile);
end

   




