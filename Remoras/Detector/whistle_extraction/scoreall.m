function results = scoreall(varargin)
% results = scoreall(Optional arguments)
% Find all detections files (ending in .det) that are children of the 
% current directory and compare them to the ground truth.  
%
% Two files are created, score.txt and score.mat:
%    score.txt - log file
%    score.mat - results data structure that can be analyzed by
%                dtAnalyzeResults to produce human readable statistics.
%
% In addition, files are created for each detection file f.wav:
% f.d- : bad detections (false positives)
% f_s.d+ : Correct detection, ground truth tonal met selection criteria
%          (See argument 'Criteria' below.)
% f_s.gt+ : Matched ground truth tonal that met selection criteria
% f_s.gt- : Missed ground truth tonal that met selection criteria
% f_a.??? : As above (.d+, .d-, .gt+, .gt-), but irrespective of ground
%           truth selection criteria.
%
% Optional arguments
% 'DetExt', Ext - Filename extension for detection files.  Default '.det'
% 'Corpus', Dir - Directory containing audio and ground truth .bin 
%              files from which detections were derived.
%              Default '.' (current directory)
% 'Detections', Dir - Directory where detections are located. Default '.'
% 'ResultName', FileBasename - Use FileBasename for .mat/.txt.  
%              Default 'score'
% 'Criteria', [dB, RatioAbove_SNR, MinLen_s] 
%       Criteria for determining whether or not to expect each ground
%       truth tonal to be detected.  When tonals are detected but we
%       did not expect them to be, they are not counted towards the
%       recall, but they will not be used to penalize the precision.
%       Default:  [10, .2, .150]
%       The following were used in DCLMMPA2011:  [10, .2, .150]

% It is recommended to keep the corpus materials (audio and ground truth
% files) separate from the detections and to use the optional Corpus and
% Detections argument.  

% defaults
detext = '.det';
FileBasename = 'score';
CorpusDir = '.';
DetectionDir = '.';
Criteria = [10, .2, .150];

start_t = tic;

% Process optional arguments
vidx = 1;
while vidx < nargin
    switch varargin{vidx}
        case 'DetExt'
            detext = varargin{vidx+1}; vidx = vidx+2;
        case 'Corpus'
            CorpusDir = varargin{vidx+1}; vidx = vidx+2;
        case 'Detections'
            DetectionDir = varargin{vidx+1}; vidx = vidx+2;
        case 'ResultName'
            FileBasename = varargin{vidx+1}; vidx = vidx+2;
        case 'Criteria'
            Criteria = varargin{vidx+1}; vidx = vidx+2;
            if ~isnumeric(Criteria)
                error('silbido', 'Bad scoring critera')
            end
        otherwise
            error('silbido', 'Bad optional argument');
    end
end

logfile = sprintf('%s_log.txt', FileBasename);
matfile = sprintf('%s.mat', FileBasename);

% make sure trailing file seperator on the CorpusDir
if CorpusDir(end) ~= filesep && CorpusDir(end) ~= '/'
    CorpusDir(end+1) = filesep;
end

% get path to detections files and their basename
[detections base] = utFindFiles({sprintf('*%s', detext)}, {'.'}, true);
% Construct names for audio and ground truth files
audio = cellfun(@(f) fullfile(CorpusDir, strrep(f, detext, '.wav')), ...
    detections, 'UniformOutput', false);
gt = cellfun(@(f) fullfile(CorpusDir, strrep(f, detext, '.bin')), ...
    detections, 'UniformOutput', false);

% Verify all files exist before we start
N = length(detections);
gtI = zeros(N,1);
audioI = zeros(N,1);
for k=1:N
    audioI(k) = exist(audio{k}, 'file') > 0;
    gtI(k) = exist(gt{k}, 'file') > 0 ;
end

flameanddie = false;
if sum(audioI) ~= N 
    fprintf('Unable to find audio data for:\n');
    fprintf('%s\n', audio{~audioI});
    flameanddie = true;
end
if sum(gtI) ~= N
    fprintf('Unable to find ground truth data for:\n');
    fprintf('%s\n', gt{~gtI});
    flameanddie = true;
end

if flameanddie
    error('silbido:missing file', 'Missing audio or ground truth');
end
diary(logfile);

% Fields of result structure and how we will modify the
% detection file name to save the tonals associated with
% detections/misses, etc.
% Before the extension:
%   _a : all tonals regardless of whether or not they meet exclusion
%        criteria.
%   _s : With respect to ground truth tonals that meet the specified
%        criteria.
% Extension consists of:
%   .d or .gt : detected tonal or ground truth
%  + : correct detection or detected ground truth
%  - : false detection or missed ground truth
result_files = {
    'falsePos', [], '.d-'           % false positives
    'all', 'detections', '_a.d+'    % good detections
    'snr', 'detections', '_s.d+'
    'all', 'gt_match', '_a.gt+'     % ground truth corresponding to detection
    'all', 'gt_miss', '_a.gt-'      % missed ground truth
    'snr', 'gt_match', '_s.gt+'
    'snr', 'gt_miss', '_s.gt-'
    };

N=1;
for idx=1:length(gt) %1:length(gt)
    
    try
        % Read detection file 
        d_tonals = dtTonalsLoad(detections{idx});
    catch
        fprintf('Skipping %s, no detections\n', base{idx});
        continue
    end
    
    % load in ground truth for comparison
    clear gt_tonal;  % Mark old one for garbage collection
    gt_tonal = dtTonalsLoad(gt{idx});

    fprintf('\nProcessing %d/%d %s\n', idx, length(gt), audio{idx});
    result = dtPerformance(audio{idx}, d_tonals, gt_tonal, ...
        'Criteria', Criteria);
    
    % Result structure contains lists of tonals
    % If we simply concatenate it into results, we will quickly
    % run out of heap space.  
    % Instead, we write out each tonal list into a file with an
    % extension specified by results_files{:,3} and store the filename
    for k=1:size(result_files, 1)
        tfname = sprintf('%s%s', ...
            detections{idx}(1:end-length(detext)), result_files{k,end});
        if isempty(result_files{k,2})
            tonals = result.(result_files{k,1});
            % Replace list with filename to avoid running out of heap space
            result.(result_files{k,1}) = tfname;
            result.([result_files{k,1}, 'N']) = tonals.size();
        else
            tonals = result.(result_files{k,1}).(result_files{k,2});
            % Replace list with filename to avoid running out of heap space
            result.(result_files{k,1}).(result_files{k,2}) = tfname;
            result.(result_files{k,1}).([result_files{k,2}, 'N']) = tonals.size();
        end
        dtTonalsSave(tfname, tonals);
        
    end
    results(N) = result;
    N=N+1;
    
    % Checkpoint every so often...
    if rem(N, 10) == 0
        fprintf('saving\n');
        save(matfile, 'results');
    end
    
    fprintf('\nElapsed time since start:  %s\n', ...
        datestr(datenum(0, 0, 0, 0, 0, toc(start_t)), 13));
end
save(matfile, 'results');
diary off;

