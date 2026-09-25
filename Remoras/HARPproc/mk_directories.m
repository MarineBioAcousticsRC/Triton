function dirs = mk_directories(disk, dataID, dfs)
    
global REMORA 

% store directories in a cell array to return
dirs = cell(1, length(dfs));

% loop through each desired decimation factor
for i = 1:length(dfs)
    
    df = dfs(i);
    drive = REMORA.hrp.saveloc{i};
    
    % decimation factor dirname of format 'CINMS_B_32_df1'
    df_dirname = sprintf('%s_df%s',dataID, num2str(df));
    if ~exist(fullfile(drive, df_dirname), 'dir') 
        mkdir(fullfile(drive, df_dirname));
    end
    
    % disk dirname of format 'CINMS_B_32_disk01'
    if df == 1 % leave out df1
        disk_dirname = fullfile(df_dirname, sprintf('%s_disk%s', dataID, disk));
    else
        disk_dirname = fullfile(df_dirname, ...
            sprintf('%s_disk%s_df%s', dataID, disk, num2str(df)));
    end

    dirs{1, i} = fullfile(drive, disk_dirname);
    
    if ~exist(dirs{1, i}, 'dir')
        mkdir(dirs{1, i});
    end
end
    