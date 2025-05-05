function ctn = batchLTSA_rename_wavs(prefix)
% BATCHLTSA_RENAME_WAVS   Rename sound files if the filenames are not valid
%
%   Syntax:
%       CTN = BATCHLTSA_RENAME_WAVS(PREFIX)
%
%   Description:
%       If the BATCHLTSA_MK_BATCH_LTSA_PRECHECK flags the input wav or flac
%       filenames as incompatible with LTSA creation (missing timestamps,
%       timestamp is not properly formatted, or filenames are not all the 
%       same length), this function will rename all the files using a 
%       provided prefix and appending the correctly formatted timestamp.
%       This only works if the files are in sequential order and have no
%       gaps. 
%
%       Note: This code is not super well tested (have not had example
%       where this was an issue) so may be buggy.
%
%       Originally from A.Allen/triton1.93.20190212_testWithHARPimage
%
%   Inputs:
%       prefix   [string] prefix created with BATCHLTSA_GEN_PREFIX based on
%                the input subdirectory to start each filename
%
%	Outputs:
%       ctn      flag to continue or not continue through the code
%
%   Examples:
%
%   See also
%
%   Authors:
%       S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%   Updated:   04 May 2025
%
%   Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS % REMORA

% TODO
% PARAMS.ltsa.indir = 'G:\data\180501_ltsa_multidir_filenames';
% PARAMS.ltsa.ftype = 1;

% continue flag (whether or not we should return)
ctn = 0;
disp_msg('Input files must have datenumbers in the filenames and must all be the same length.');


if PARAMS.ltsa.ftype == 2
    files = dir(fullfile(PARAMS.ltsa.indir, '*.x.wav'));
    fmt = 'xwav';
elseif PARAMS.ltsa.ftype == 1
    files = dir(fullfile(PARAMS.ltsa.indir, '*.wav'));
    fmt = 'wav';
end

q_str = sprintf('Warning - %s files found with incompatible filenames. Rename?',fmt);
a = questdlg(q_str, 'Rename files?');

if strcmp(a, 'No') && ~strcmp(a, 'Yes')
    disp_msg('Cancelled.');
    return
end

% put all the filenames in a cell array
fnames = {};
for k = 1:length(files)
    fnames{end+1} = files(k).name;
end

% don't look at this code it's super ugly
fig_title = sprintf('Rename %s files', fmt);
fig = figure('Name', fig_title, 'Units', ...
    'normalized', 'MenuBar', 'none', 'NumberTitle', 'off');
movegui(gcf, 'center');
g = [0.8,0.8,0.8];
txt_str = sprintf('File order preview for %s', PARAMS.ltsa.indir);
fig_stat_txt = uicontrol(fig,'Units','normalized','Style','text','string',...
    txt_str, 'Position', [0.0339, 0.852, 0.6, 0.1],'BackgroundColor',g,...
    'HorizontalAlignment','left');
fig_list = uicontrol(fig,'Units','normalized','Style','listbox','string',...
    fnames, 'Position', [0.0339, .1, 0.6, 0.8]);
fig_opts = uicontrol(fig,'Units','normalized','Style','text','string',...
    'Directory sorting method','BackgroundColor',g,...
    'Position', [0.68, .8, 0.4, 0.15],'HorizontalAlignment','left');
fig_alph_rad = uicontrol(fig,'Units','normalized','Style','radiobutton',...
    'String','Alphabetical','Value',1,'Position',[0.68,0.8,0.4,0.1],...
    'BackgroundColor',g,'Callback',@alpha_sort);
fig_num_rad = uicontrol(fig,'Units','normalized','Style','radiobutton',...
    'String','Numerical','Value',0,'Position',[0.68,0.72,0.4,0.1],...
    'BackgroundColor',g,'Callback',@num_sort);
fig_date_stat_txt = uicontrol(fig,'Units','normalized','Style','text',...
    'String','Data start date:','BackgroundColor',g,'HorizontalAlignment',...
    'left','Position',[0.68, .5, 0.4, 0.15]);
fig_date_ed_txt = uicontrol(fig,'Units','normalized','Style','edit',...
    'String','01/01/2000 00:00:00.000','HorizontalAlignment','left',...
    'Position',[0.68, .48, 0.3, 0.1]);
fig_go = uicontrol(fig,'Units','normalized','Style','pushbutton','String',...
    'Convert filenames','Position',[0.64,0.1,0.1725,0.1],...
    'Callback', @convert_names);
fig_nvm = uicontrol(fig,'Units','normalized','Style','pushbutton','String',...
    'I''ll do it myself','Position',[0.82,0.1,0.1725,0.1],...
    'Callback', @nope); 

timestamp = 0;
uiwait(fig);

% if user did not want to continue
if ~ctn
    return
%     REMORA.batchLTSA.cancelled = 1; this would cancel ALL LTSAs
end

% open a logfile for name changes
indir = PARAMS.ltsa.indir;
logfile = fullfile(indir, 'rename_log.txt');
log_out = fopen(logfile, 'w');

% convert names
for k = 1:size(fnames,  2)

    % info on current file
    curr_fname = fnames{k};
    info = audioinfo(fullfile(indir, curr_fname));
    
    % timing info
    if k == 1
        timestr = datestr(timestamp, 'yymmdd_HHMMSS');
    else
        dur = info.TotalSamples*(1/info.SampleRate);
        timestamp = dur/86400+timestamp;
        timestr = datestr(timestamp, 'yymmdd_HHMMSS');
    end
    
    new_fname = sprintf('%s%s.wav', prefix, timestr);
    
    % rename the file with better name
    fwrite(log_out, sprintf('%s -> %s \n', curr_fname, new_fname));
    fprintf('%s -> %s \n', curr_fname, new_fname);
    curr = fullfile(indir, curr_fname);
    new_fname = fullfile(indir, sprintf('%s%s.wav', prefix, timestr));
    movefile(curr, new_fname);    
end

fclose(log_out);
fprintf('Renames completed.\n');


% sort entries in the directory alphabetically
function alpha_sort(~, ~)
    
    % swap if needed
    if get(fig_num_rad, 'Value') 
        set(fig_num_rad, 'Value', 0);
    end
    
    % put all the filenames in a cell array
    fnames = {};
    for k = 1:length(files)
        fnames{end+1} = files(k).name;
    end 
    
    % change way that files are displayed in window
    fnames = sort(fnames);
    set(fig_list, 'String', fnames);
    
end

% sort entries in the directory numerically, by the first numerical entry
% found in each filename
function num_sort(~,~)
    
    % swap if needed
    if get(fig_alph_rad, 'Value') 
        set(fig_alph_rad, 'Value', 0);
    end
    
    % if we enabled it, sort dir
    if get(fig_num_rad, 'Value')
    
        % put all the filenames in a cell array
        fnames = {};
        num_inds = zeros(length(files), 1);
        for k = 1:length(files)
            fnames{end+1} = files(k).name;
            fname = files(k).name;
            thing = regexp(fname, '[0-9]+', 'match');
            thing = thing{1}; % take the first number found in each fname
            num_inds(k) = str2double(thing);
        end 
        
        % sort the filenames according to first number found in each
        % filename
        [~, order] = sort(num_inds);
        fnames = fnames(order);
        fnames = reshape(fnames, [size(fnames, 2), size(fnames, 1)]);
        
        % change the order the dirs are listed in 
        set(fig_list, 'String', fnames);
    end
    
end

% user does not want to rename files
function nope(~, ~)
    close(fig);
    ctn = 0;
    return
end

% user wants to rename files
function convert_names(~, ~)
    try
        timestamp = datenum(get(fig_date_ed_txt, 'String'));
        close(fig);
        ctn = 1;
    catch
        warndlg('Invalid date format')
    end
end

end