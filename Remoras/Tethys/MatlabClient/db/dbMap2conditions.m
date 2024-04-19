function conditions = dbMap2conditions(deployments)

%creates a bunch of conditions separated by OR for an xquery where clause. 
%It is used after creating a bounding box from which to pull detections from. 
%E.g., after retriving all of the deployments located in lat/long bounds, 
%it will create a where clause for them all. 
%This should be updated (and tested) to use a sequence, rather than multiple OR's,
% as described here: 
%http://stackoverflow.com/questions/36928642/where-clause-to-determine-if-element-value-is-in-a-sequence-xq



%row indices for cell array produced from deployment struct
site_idx = 3;
dep_idx = 2;
proj_idx = 1;

%convert to cell array
deployment_box_cells = struct2cell(deployments);


%get the sites and projects
projects = unique([deployment_box_cells{proj_idx,:}]);

xq_map = {};

N_projects = length(projects);
%if theres more than one project, we need to track which columns belong to
%it

map_row_idx = 1; %keeps track of the row we're on in the xq map

for pidx=1:N_projects
    project_name = projects{pidx};
    columns = find(cellfun(@(val) strcmp(val,project_name), deployment_box_cells(proj_idx,:)));
    %project_map{column_indicies_idx,i} = columns;
    proj_start_col = columns(1);
    proj_end_col = columns(end);
    %create a subarray for this specific project's deployment info
    dep_cells = deployment_box_cells(1:3,proj_start_col:proj_end_col);
    %get the sites for this project
    sites = unique([dep_cells{site_idx,:}]);
    N_sites = length(sites);
    for sidx=1:N_sites
        site_name = sites{sidx};
        %get the deployments for this site
        site_columns = find(cellfun(@(val) strcmp(val,sites{sidx}), dep_cells(site_idx,:)));
        
        %loop through these columns, pulling out each deployment for it
        deps = zeros(1,length(site_columns));
        didx=1;
        for dep_col = site_columns
            deps(didx) = dep_cells{dep_idx,dep_col}{1};
            didx = didx+1;
        end
        xq_map(map_row_idx,:) = {project_name,site_name,deps};
        map_row_idx = map_row_idx+1;
    end
end


%create a series of where clauses based on the input map
[rowN,colN] = size(xq_map);

site_idx = 2;
dep_idx = 3;
proj_idx = 1;

conditions = '';
conj_meta = 'where';

for i = 1:rowN
    project = xq_map{i,proj_idx};
    proj_condition = sprintf('$det/DataSource/Project = "%s"',project);
    site = xq_map{i,site_idx};
    site_condition = sprintf('$det/DataSource/Site = "%s"',site);
    deployments = xq_map{i,dep_idx};
    
    if length(deployments)==1
        dep_conditions = sprintf('$det/DataSource/Deployment = %d',deployments);
    else
        dep_conditions = '';
        conj_dep = '';
        %loop through all the deployments for this project/site
        for j = deployments
            dep_cond = sprintf('%s $det/DataSource/Deployment = %d',conj_dep, j);
            dep_conditions = sprintf('%s %s',dep_conditions,dep_cond);
            conj_dep = 'or';
        end
    end

    conditions = sprintf('%s%s %s and %s and (%s)\n',...
        conditions, conj_meta, proj_condition,site_condition,dep_conditions);
    conj_meta = 'or';
    
end