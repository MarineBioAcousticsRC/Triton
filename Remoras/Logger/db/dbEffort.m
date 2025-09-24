function dbEffort(queries, detector)

project = 'SOCAL';
EffortSpanPrev = [];

for sitecell = {'M', 'N'}
    site = sitecell{1};  % Get copy without cell array
    
    for deploy = [32 33 34 35 36 37]
        
        % find species for which we have effort
        [effort, details] = dbGetEffort(queries, ...
            'Site', site, 'Deployment', deploy, 'Project', project, ...
            'Detector', detector);
       
        start(deploy) = effort(1);
        stop(deploy) = effort(2);
    end
end

fid = fopen('effort.txt','wt');
fprintf(fid, '%5.4f %5.4f\n', start,stop);
fclose(fid);