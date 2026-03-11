function [deployments, dom] = dbDeploymentInfo(query_eng, varargin)
% [deployments, dom] = dbDeploymentInfo(query_eng, OptArgs)
% Returns an array where each element is a structure
% with fields about fixed deployments.  Records are selected 
% based on the following optional arguments which fall into two
% categories
%
% Equality checks:  Specified value must be equal (case independent)
% to the string provided
% 'Project', string - Name of project data is associated with, e.g. SOCAL
% 'Region', string
% 'Site', string - name of location where data was collected
%
% Floating point comparisions:  
% 'DeploymentID', Comparison
% 'DeploymentDetails/Latitude', Comparison
% 'DeploymentDetails/Longitude', Comparison
% 'DeploymentDetails/Depth_m', Comparison
% Comparison consists of either a:
%   scalar - queries for equality
%   cell array {operator, scalar} - Operator is a relational
%       operator in {'=', '<', '<=', '>', '>='} which is compared
%       to the specified scalar.
%
% Optional Args:
% 'ShowQuery', true|false(Default) - Display the constructed XQuery
%
1;

meta_conditions = '';  % selection criteria for detection meta data
show_query = false; %Do not display the XQuery
benchmark=false; %do not benchmark unless user specifies

% condition prefix/cojunction
% First time used contains where to form the where clause.
% On subsequent uses it is changed to the conjunction and
conj_meta = 'where';
idx=1;
while idx < length(varargin)
    switch varargin{idx}
        % Deployment details
        case {'Project', 'Region', 'Site'}
            meta_conditions = ...
                sprintf('%s%s %s', meta_conditions, conj_meta, ...
                    dbListMemberOp(...
                       sprintf('$deployment/%s', varargin{idx}), ...
                       varargin{idx+1}));
            conj_meta = ' and';
            idx = idx+2;
        case {'DeploymentID', 'DeploymentDetails/Latitude', ...
                'DeploymentDetails/Longitude', 'DeploymentDetails/DepthInstrument_m'}
            comparison = dbRelOp(varargin{idx}, ...
                '$deployment/%s', varargin{idx+1});
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison); 
            conj_meta = ' and';
            idx = idx+2;
        case {'DeploymentDetails/TimeStamp'}
            comparison = dbRelOpChar(varargin{idx}, ...
                '$deployment/%s', varargin{idx+1});
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison); 
            conj_meta = ' and';
            idx = idx+2;
        case 'ShowQuery'
            show_query = varargin{idx+1};
            idx = idx+2;
        case 'Benchmark'
            bench_path=varargin{idx+1};
            benchmark = true;
            idx = idx+2;
        otherwise
            error('Bad argument %s', varargin{idx});
    end
end

% Build the query 
query_template = dbGetCannedQuery('GetDeployments.xq');
query_str = sprintf(query_template, meta_conditions);

% Display XQuery
if show_query
    fprintf(query_str);
end
1;

%Execute Query
dom = query_eng.QueryReturnDoc(query_str);
% convert to Matlab structure
if benchmark
    tic; %time it
end

[tree, tree_name] = xml_read(dom);
if isempty(tree) || (isfield(tree, 'CONTENT') && isempty(tree.CONTENT))
    deployments = [];
else
    deployments = tree.ty_COLON_Deployment;
end

if benchmark
    %time it
    elapsed = toc;
    bench_file = fullfile(bench_path,...
        sprintf('%s_deployment.txt',datestr(today(),'yyyy-mm-dd')));
    summary_file=(fullfile(bench_path,'1deployment_summary.txt'));
    summ_fid = fopen(summary_file,'at');
    bench_fid=fopen(bench_file,'at');
    %TODO - make project/site/deployment variables
    %print whole query and elapsed time
    fprintf(bench_fid,'Query %s:\n"""\n%s\n"""\n>>%.3fs elapsed; %d_returned\n\n',datestr(now(),'yyyy-mm-ddTHH:MM:SS.FFF-0700'),query_str,elapsed,length(deployments));
    %append to summary file
    fprintf(summ_fid,'%s...%d_returned %.3f,\n', datestr(now(),'yyyy-mm-ddTHH:MM:SS.FFF-0700'),length(deployments),elapsed);
    fclose(bench_fid);
    fclose(summ_fid);
end
1;
