function query_h = dbInit(varargin)
% dbInit(optional_args)
% Create a connection to the Tethys database.
% With no arguments, a connection is created to the default server
% defined within this function.
% 
% Optional arguments:
% 'Server', NameString - name of server or IP address
%           Use 'localhost' if the server is running the
%           same machine as where the client is executing.
% 'Port', N - port number on which server is running
% 'Secure', false (default)|true - make connection over a secure socket
% 'TransportLayer', 'xmlrpc'|'REST'
%           Describes transport layer mechanism.  Default 'REST'
%           This must match the server transport layer mechanism.

% 'NAT', false (default) | true - Most users can ignore this switch.
%          It should only be used when communicating with a Tethys server
%          attached to a router providing network address translation and
%          clients will be connecting from both within the NAT network and
%          the wider network.  One possible sign of a NAT network is when
%          some of the clients have private network IP addresses:
%               10.x.x.x, 172.16.x.x:172.31.x.x, or 192.168.x.x
%          and other clients do not.  Contact your network administrator
%          if you are not sure.
%          In general, using a NAT network can create problem for
%          the Secure option as it may be harder to verify self-signed
%          certificates.
%
% Returns a handle to a query object through which Tethys queries
% are served.

dbJavaPaths();  % Ensure that Java code is on our javaclasspath

xmlServerSpec = 'ServerDefault.xml';
transport_layer = 'REST';

% Setup defaults as the XML default specification may be absent
% or incomplete
port = 9779;
server = '127.0.0.1'; %local


% other defaults
NAT_InternalExternal = false;
secure = false;
localhost_ip = '127.0.0.1';
server_nat_ip = [127 0 0 1];  % default for when there is no NAT

% Used for determining IP when on a NAT network
wan_ip = 'http://roch.sdsu.edu/report_client_ip.shtml?nocache=1';

% Read in default parameters from XML specification if it exists
% XML specification is expected in either the parent directory
% or a sibling grandparent of this directory named server
curr_dir = fileparts(which(mfilename));  % access parent directory
parent = fileparts(curr_dir);
tethys_root = fileparts(parent);
xmldefaults = fullfile(tethys_root, xmlServerSpec);
%if it doesnt exist in root...
if ~ exist(xmldefaults, 'file')
  % check parent of current directory
  xmldefaults = fullfile(parent, xmlServerSpec);
  if ~ exist(xmldefaults, 'file');
    xmldefaults = [];  % couldn't find anything
  end
end
  
if ~isempty(xmldefaults)
    options.Str2Num = 'never';  % Don't interpret IP addresses as numbers
    defaults = xml_read(xmldefaults, options);
    if isfield(defaults, 'Name')
        server = defaults.Name;
    end
    if isfield(defaults, 'NATIP')
        %this is broken
        server_nat_ip = sscanf(strrep(defaults.NATIP, '.', ' '), '%f')';
    end
    if isfield(defaults, 'Port')
        port = str2double(defaults.Port);
    end
end

vidx = 1;
while vidx < length(varargin)
    switch varargin{vidx}
        case 'Server'
            server = varargin{vidx+1}; vidx = vidx+2;
        case 'Secure'
            secure = varargin{vidx+1}; vidx = vidx+2;
        case 'Port'
            port = varargin{vidx+1}; vidx = vidx+2;
        case 'TransportLayer'
            transport_layer = varargin{vidx+1}; vidx = vidx+2;
        case 'NAT'
            NAT_InternalExternal = varargin{vidx+1}; vidx = vidx+2;
        otherwise
            error('Unknown optional argument %s', varargin{vidx});
    end
end

% We try to avoid modifying the name given by the usr as it may
% impact certificate verification if the user is using secure
% socket layer (https://).
% 
% However, if the server is running behind a router that does
% network address translation (NAT,e.g computers assigned IP
% addresses of the form 10.x.x.x, 172.16.x.x:172.31.x.x, or 
% 192.168.x.x) and the server is expected to serve clients
% both within and without the network, clients need to be able
% to determine whether or not the name should be converted to
% a local NAT address or retain the NAT's exernal address.
if NAT_InternalExternal
    if (strcmp(server, 'localhost'))
        server = localhost_ip;
    else
        import java.net.*;
        import java.io.*;
        
        
        
        try
            % get server name
            server_inet = java.net.InetAddress.getByName(server);
            server_ip = char(server_inet.getHostAddress());
            
            % Determine our IP
            my_ip_url = URL(wan_ip);
            in = BufferedReader(InputStreamReader(my_ip_url.openStream()));
            % Read until we hit the first line without an element start tag
            my_ip = char(in.readLine());
            while my_ip(1) == '<'
                my_ip = char(in.readLine());
            end
            
        catch e
            fprintf('Unable to determine IP, assuming local host');
            my_ip = [];
        end
        
        if isempty(my_ip)
            % no network connectivity, assume on local host
            server = localhost_ip;
        else
            
            % Find all IPs associated with this host
            if strcmp(my_ip, server_ip)
                % client and server have the same IP
                % If the server is on a private network using NAT, they
                % might not be the same machine.  Determine whether to
                % use loopback address or the server on the NAT.
                server_nat_inet = java.net.InetAddress.getByAddress(server_nat_ip);
                server_nat_host = server_nat_inet.getHostName();
                
                % pull up one of the local nodes IPs.  As some machines
                % will have multiple interfaces, it might not be the one
                % used to address the database on the local NAT node.
                local_nat_ip = java.net.InetAddress.getLocalHost();
                % Compare host names
                if server_nat_host.compareTo(local_nat_ip.getHostName()) == 0
                    % Same node, use loopback
                    server = localhost_ip;
                else
                    server = sprintf('%d.%d.%d.%d', server_nat_ip);
                end
            else
                server = server_ip;
            end
        end
    end
end

% Used to be inline code, but now that Java paths are setup inside this
% function it appears that there is a bug in the search path, most likely
% due to the just in time compiler not detecting the side-effect of a
% Java class search path change.
query_h = dbInitQueryHandler(server, port, secure, transport_layer);

