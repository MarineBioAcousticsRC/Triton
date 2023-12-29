function set_tethys_server()
% query_h = set_tethys_server()
% Initialize a Tethys query handler, prompts for server parameters
% and verifies that we can speak to the server.
% Store Tethys query handler instance in a REMORA global.

global REMORA
global PARAMS

% Set up data structures for dialog
formats = struct('type', {}, 'style', {}, 'items', {}, ...
  'format', {}, 'limits', {}, 'size', {});

formats(1).type = 'edit';
formats(1).format = 'text';

formats(2).type = 'edit';
formats(2).format = 'integer';

formats(3).type = 'check';
formats(3).format = 'logical';

formats = formats';  % expects Nx1, not 1xN

prompts = {'Server machine name', 'Server port', 'Use secure socket layer'}';
defaults = {'spyhop.ucsd.edu', 80, false}';

prompt = 'Specify Tethys Server';


% Request from user until they cancel or get it right
connected = false;
canceled = false;
while ~ (canceled || connected)
    [answer, canceled] = inputsdlg(prompts, {prompt}, formats, defaults);
    if ~ canceled
        q = dbInit('Server', answer{1}, 'Port', answer{2}, 'Secure', answer{3});
        url = char(q.getURLString());
        f = uifigure();
        p = uiprogressdlg(f, 'Title', ...
            ['Contacting Tethys server at ', url], ...
            'Indeterminate', 'on');
        drawnow();
        try
            connected = q.ping();
        catch
            connected = false;
        end
        delete(f);
        if ~ connected
            prompt = sprintf('Server %s down or incorrect parameters', url);
        end
    end
end

if canceled
    q = [];
end

REMORA.tethys.query_h = q;
1;
end



