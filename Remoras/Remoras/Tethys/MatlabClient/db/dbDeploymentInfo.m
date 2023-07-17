function deployments = dbDeploymentInfo(queryEngine, varargin)
% deployments = dbDeploymentInfo(query_engine, OptArgs)
% Return information about deployments.
% The function dbGetDeployments has an identical interface
% and is the preferred way to retrieving deployments.

fprintf("dbDeploymentInfo is being replaced by dbGetDeployments\n");
fprintf("Update your code to avoid breakage in future releases\n");
deployments = dbGetDeployments(queryEngine, varargin{:});