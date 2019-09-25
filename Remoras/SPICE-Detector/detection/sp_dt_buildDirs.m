function [p] = sp_dt_buildDirs(p)
% build output directories

if ~isempty(p.outDir) % use outDir if specified
    p.metaDir = fullfile(p.outDir,[p.depl,'_','metadata']);
else  % otherwise use baseDir
    p.metaDir = fullfile(p.baseDir,[p.depl,'_','metadata']);
end

if ~isdir(p.metaDir)
    mkdir(p.metaDir)
end