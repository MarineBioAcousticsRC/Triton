% function checktagpath(tag)
% Troubleshoot dtag toolbox setup
% 
% Will run through and check the following:
% -Are tag tools installed?
% -Do tag paths exist (AUDIO, PRH, CAL)?
% -Do tag PRH and CAL files exist?
% -Is the deployment directory correct?
% -Are WAV files in the deployment directory?
% -Does cuetab exist, or can it be generated?
%
% If errors are found, these settings must be fixed.
% Tag tools must be in place, tag paths must be set correct, prh and cal
% files must be generated and located in correct directory, and wav files
% (and other tag files such as wavt, xml, swv) must be in the correct
% deployment directory.
%
% F. H. Jensen and M. B. Kaplan, 2014
function [] = checktagpath(tag)

if ~length(tag)==9,
    error(' Tag deployment ID must be 9 digits, e.g. gm10_231a')
end

% Use subscript to find correct tag type based on existing CAL file
tagver = dtagtype(tag) ;

% Check for important tag toolboxes

% All tags need standard dtag toolbox
if ~exist('tagwavread.m')
	disp('Unable to find default dtag2 toolbox')
end

% Version 3 dtags also need additional DTAG3 specific tools and XML4MATv2 toolbox
if tagver == 3
	if ~exist('simplify_mbml.m')
        disp('Unable to find XML4MATv2 toolbox')
    end
    
    if ~exist('d3wavread.m')
        disp('Unable to find dtag3 toolbox')
    end 
end

% Check whether tag paths actually exist
global TAG_PATHS

if ~exist(TAG_PATHS.CAL)
    disp([' Current CAL directory not found: ' TAG_PATHS.CAL ])
end

if ~exist(TAG_PATHS.PRH)
    disp([' Current PRH directory not found: ' TAG_PATHS.PRH ])
end

if ~exist(TAG_PATHS.AUDIT)
    disp([' Current AUDIT directory not found: ' TAG_PATHS.AUDIT ])
end

if ~exist(TAG_PATHS.AUDIO)
    disp([' Current AUDIO directory not found: ' TAG_PATHS.AUDIO])
end

% Then check if there are actually CAL and PRH files for this tag
caldir = TAG_PATHS.CAL;
prhdir = TAG_PATHS.PRH;

% Check cal file
if ~exist([caldir '\' tag 'cal.xml']) && ~exist([caldir '\' tag 'cal.mat'])
    if tagver==2,
        disp([' CAL file not found: ' caldir '/' tag 'cal.mat'])
    elseif tagver==2,
        disp([' CAL file not found: ' caldir '/' tag 'cal.xml'])
    else
        disp(' CAL file not found')
    end
end

% Check prh file
if ~exist([prhdir '\' tag 'prh.mat']) 
    disp([' PRH file not found: ' prhdir '/' tag 'prh.mat'])
end

% Now check audio files and original dtag data
if tagver == 2,
    wavfile = makefname(tag,'AUDIO');
elseif tagver == 3,
    wavfile = d3makefname(tag,'AUDIO');
else % Correct tag version not detected, skip looking for wav files
    wavfile = [];
end

% Then find deployment directory
deploydir = wavfile(1:max(findstr(wavfile,'/')));

if tagver
    if ~exist(deploydir),
        disp([' Deployment directory not detected: ' deploydir])
    elseif ~exist(wavfile),
        disp([' WAV files not found: ' wavfile])
    else
        % If both deployment directory and wave files exist, try to see if
        % cue tab exists or can be created
        if tagver == 2,
            loadcal(tag,'CUETAB') ;
            if ~exist('CUETAB')
                % We have already provided 
            elseif isstruct(CUETAB),
                disp(' Error: CUETAB in cal file is a structure (likely CUETAB.N) but needs to be an n x 11 matrix')
                disp(' Clear everything, load cue file, check and redefine cuetab, then use savecal to save cuetab info')
            elseif ~size(CUETAB,2)==11,
                disp(' CUETAB in cal file does not have expected amount of columns')
            end
        elseif tagver == 3,
            recdir = d3makefname(tag,'RECDIR'); % make recdir based on user input
            prefix = [tag(1:2) tag(6:9)]; % define prefix
            suffix = 'wav';
            cuefname = [recdir prefix suffix 'cues.mat'] ;
            if ~exist(cuefname,'file')
                try
                    cuefname = makecuefile(recdir,prefix,suffix) ;
                catch
                    disp('Could not create cue file')
                end
            end    
        end

    end
else
    disp('Cannot test audio directory without cal file')
end

disp(' Checktagpath complete. Correct concerns listed above, if any')
