% explosions_excel_export.m
% Exports explosions verification data from "bt" into Excel
% Must run this program from within the explosions folder
% Updated to export only 1s in bt and skip over empty bt files

clear all; close all;

files = dir('F:\SOCAL47H\explosions\*.mat'); % Set folder path
% Make sure there is a \ before the *.mat

jj = 1;
nn = 1;
place = 0;

% Load bt data from each mat file and store into bt_combined array
for k = 1:length(files)
    load(files(k).name);
    [len,wid] = size(bt);
    if len ~= 0
        if place == 0
            for j = 1:len
                if bt(j,3) == 1
                    bt_combined(jj,:) = bt(j,:);
                    jj = jj+1;
                end
            end
        else
            place = length(bt_combined(:,1))+1; % location of row for start of next bt
            for n = 1:len
                if bt(n,3) == 1
                    bt_combine(nn,:) = bt(n,:);
                    nn = nn+1;
                end
                if bt(n,:) ~= 0
                    kk = place+length(bt_combine(:,1));
                    for m = place:kk-1
                        bt_combined(m,:) = bt_combine(m-place+1,:);
                    end
                end
            end
        end
    end
    disp(['Added bt #' num2str(k) ' out of ' num2str(length(files)) ' to bt_combined']);
    clear bt;
    clear bt_combine;
    nn = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert matlab times to excel times
excelStart = bt_combined(:,4)-ones(size(bt_combined(:,4))).*datenum('30-Dec-1899');
excelEnd = bt_combined(:,5)-ones(size(bt_combined(:,5))).*datenum('30-Dec-1899');

% Exports the bt_combined array data into excel file
lengt = length(bt_combined)+1;
cellmat = cell(lengt,5);
cellmat{1,1} = 'Sample Points 1';
cellmat{1,2} = 'Sample Points 2';
cellmat{1,3} = 'Detection';
cellmat{1,4} = 'Start Time';
cellmat{1,5} = 'End Time';

for idx = 1:length(bt_combined)
    cellmat{idx+1,1} = bt_combined(idx,1);
    cellmat{idx+1,2} = bt_combined(idx,2);
    cellmat{idx+1,3} = bt_combined(idx,3);
    cellmat{idx+1,4} = excelStart(idx,1);
    cellmat{idx+1,5} = excelEnd(idx,1);
end

xlswrite('SOCAL47H_explosions.xls', cellmat); % Rename this each time
disp('Finished writing data to excel file');


