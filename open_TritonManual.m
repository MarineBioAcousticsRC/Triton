function open_TritonManual
% open up triton manual in adobe acrobat pdf
%   
global PARAMS
%   TritonManualPath = fileparts(which('triton'));
%   TritonManual = strcat(TritonManualPath,'\','TritonUserManual.pdf');
  TritonManual = fullfile(PARAMS.path.Extras,'TritonUserManual.pdf');
  winopen(TritonManual);

end

