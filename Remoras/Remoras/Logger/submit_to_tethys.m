function submit_to_tethys(varargin)
% submit_to_tethys(...)
% Start Tethys submission process
% Arguments are not used for this callback.

% Retrieve current server
server = get_tethys_server();

if isempty(server)
    dbSubmit();
else
    dbSubmit(server);
end