function success = ckFirmware()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sets variable values based on what firmware version the HRP file comes
% from
%
% 20170628 fr - updated to add check for if we even found the firmware
% version we passed in
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS
vnum = PARAMS.head.firmwareVersion;
% vnum = 'V2.10';
success = 1;

% make sure we switch back to correct directory after reading table in
curr_dir = pwd;
path = fileparts(which('triton'));
FWcsv = which('table_ckFirmware.csv');
% cd(fullfile(path, 'Remoras\HRP'));


% fwTable = readtable('table_ckFirmware.csv', 'Format', '%s%f%f%f%f%f%f%f%f%f%f%f%f%f');
fwTable = readtable(FWcsv, 'Format', '%s%f%f%f%f%f%f%f%f%f%f%f%*s');

fwCell = table2cell(fwTable);

% loop through rows of table to find matching vnum entry
for i = 1:size(fwCell, 1) 
    if any(findstr(vnum, fwCell{i, 1})) == 1
        vInd = i; % firmware version row index
    end
end

% did we find the firmware version?
if ~exist('vInd', 'var')
    err_str = ['Error: no matching firmware version for ', vnum,...
        '. Please update table_ckFirmware.csv.'];
    disp_msg(err_str);
    disp(err_str);
    success = 0;
    return
end

PARAMS.cflag = fwCell{vInd, 2}; % 2 = cflag ind
PARAMS.ctype = fwCell{vInd, 3}; % 3 = ctype ind
PARAMS.nch = fwCell{vInd, 4}; % 4 = nch ind
% PARAMS.fs = fwCell{vInd, 5}; % 5 = sample rate ind
PARAMS.SATA_bool = fwCell{vInd, 5}; % 5 = SATA_bool ind
PARAMS.nsampPerRawFile = fwCell{vInd, 6}; % 6 = samples/raw file ind
PARAMS.nsampPerSect = fwCell{vInd, 7}; % 7 = samples/sector ind
PARAMS.nBits = fwCell{vInd, 8}; % 8 = bits per sample
PARAMS.nsectPerRawFile = fwCell{vInd, 9};  % 9 = sectors/raw file
PARAMS.nBytesPerSect = fwCell{vInd, 10}; % 10 = bytes/sect
PARAMS.compressionFactor = fwCell{vInd, 11}; % 11 = compression factor
PARAMS.tailblk = fwCell{vInd, 12}; % 12 = 0 padding on tail
% PARAMS.bitsPerSamp = fwCell{vInd, 14}; % 14 = bits/sample
PARAMS.bitsPerSamp = PARAMS.nBits/8;

% Things to print out if issues are encountered
% disp(vnum);
% 
% fprintf('cflag : %d \n', PARAMS.cflag);
% fprintf('ctype : %d \n', PARAMS.ctype);
% fprintf('fs : %d \n', PARAMS.fs);
% fprintf('nch : %d \n', PARAMS.nch);
% fprintf('nsampPerRawFile : %d \n', PARAMS.nsampPerRawFile);
% fprintf('nsampPerSect : %d \n', PARAMS.nsampPerSect);
% fprintf('nBits : %d \n', PARAMS.nBits);
% fprintf('nsectPerRawFile : %d \n', PARAMS.nsectPerRawFile);
% fprintf('compressionFactor : %d \n', PARAMS.compressionFactor);
% fprintf('tailblk : %d \n', PARAMS.tailblk);

cd(curr_dir);

end

