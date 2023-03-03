function query_h = get_tethys_server()
% query_h = get_tethys_server()
% Retrieve Tethys query handler, will prompt if one has not been declared.

global REMORA

if ~ isfield(REMORA.tethys, 'query_h');
    set_tethys_server();
end
    
query_h = REMORA.tethys.query_h;

if isempty(query_h)
    warning('Tethys query handler not properly initialized or server down');
end


