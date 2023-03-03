function deployment_id = log_getdeploymentids()
% deployment_id = log_getdeploymentids()
% Retrieve a string array of Ids for deployments currently in Tethys

query_h = get_tethys_server();
% Retrieve valid deployment identifiers if we have a valid query handler
if ~ isempty(query_h)
    try
        dep = dbGetDeployments(query_h, "return", "Id");
        deployment_id = sort(string(arrayfun(@(x) x.Deployment.Id, dep)));
    catch e
        deployment_id = [];
        fprintf("Unable to query Tethys, list of valid deployment identifiers unavailable\n")
        fprintf("Error:\n")
        e
    end
else
    deployment_id = [];
end