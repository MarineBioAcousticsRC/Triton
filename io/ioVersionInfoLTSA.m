function Info = ioVersionInfoLTSA(version)
% Info = ioVersionInfoLTSA(version)
% Get information about LTSA versions.
% Returns structure with information that varies by LTSA version
%
% %Id%

vidx = 1;
ver{vidx}.version = vidx;
ver{vidx}.fnamelen = 40;   % length of filename field
ver{vidx}.core_hdr_bytes = 64;  % size of header fields without directory entries
ver{vidx}.dir_start_posn = ver{vidx}.core_hdr_bytes; % first byte dir entries
ver{vidx}.dir_entry_bytes = 64;  % # bytes per directory entry (includes dir_pad)
ver{vidx}.dir_pad = 9;     % # bytes to pad directory entry

vidx = 2;
ver{vidx}.version = vidx;
ver{vidx}.fnamelen = 40;   % length of filename field
ver{vidx}.core_hdr_bytes = 64;  % size of header fields without directory entries
ver{vidx}.dir_start_posn = ver{vidx}.core_hdr_bytes; % first byte dir entries
ver{vidx}.dir_entry_bytes = 64;  % # bytes per directory entry (includes dir_pad)
ver{vidx}.dir_pad = 9;     % # bytes to pad directory entry

vidx = 4; 
ver{vidx}.version = vidx;
ver{vidx}.fnamelen = 80;   % length of filename field
ver{vidx}.core_hdr_bytes = 64;  % size of header fields without directory entries
ver{vidx}.dir_start_posn = ver{vidx}.core_hdr_bytes; % first byte dir entries
ver{vidx}.dir_entry_bytes = 101;  % # bytes per directory entry (includes dir_pad)
ver{vidx}.dir_pad = 7;     % # bytes to pad directory entry

vidx = 255; %null delimited version
ver{vidx}.version = vidx;
ver{vidx}.date_regexp = 512;    % Field containing regular expressions
                                % for parsing time.
ver{vidx}.core_hdr_bytes = 1024;  
ver{vidx}.dir_start_posn = ver{vidx}.core_hdr_bytes;
ver{vidx}.fnamelen = 2048; % length of filename field
ver{vidx}.dir_entry_bytes = 2080; % # bytes per directory entry (includes dir_pad)
ver{vidx}.dir_pad = 17; % Number of bytes to pad directory entry


error(nargchk(0, 1, nargin, 'struct'));
if nargin == 0
  version = length(ver);
end

Info = ver{version}; 

