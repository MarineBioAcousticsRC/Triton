% s = tinyxml2_tethys(mode, data, typemap)
% Read in an XML file and represent it as a Matlab strcture.
% mode - How the file should be read
%  'load' - load file whose filename is in data
%  'parse' - parse char string in data
% data - filename (load) or XML character string (parse)
% typemap - Two dimensional cell array.  Each row describes how
%   an element name is converted from a string to another type.
%
% Example:
%
%   % A map of types to send to the wrapper, in Key/Value pairs
%   % Each key represents an element name, and the strings to
%   % a return type.
% typemap={
%    'idx','double';...
%    'Deployment','double';...
%    'Start','datetime';...
%    'End','datetime';...
%    'BinSize_m', 'double'; ...
%    };
% tree = tinyxml2_tethys('parse', xml, typemap);
% tree is a structure representing the XML
%

% This code only executes when there is no Matlab executable for
% this function.
% It lets the user know the problem and how to fix it.
dir = fileparts(which(mfilename));
fprintf('%s is a Matlab executable (mex) file which must be compiled\n', mfilename);
mexfile = fullfile(dir, [mfilename, '.', mexext]);
fprintf('The file %s is not present and must be compiled\n')
fprintf('You must have a Matlab supported compiler installed\n')
fprintf('See https://www.mathworks.com/support/requirements/supported-compilers.html for a list of supported compilers\n');
fprintf('\nAfter setting up your environment (see the -setup section of doc("mex"))\n')
fprintf('Execute the following at the Matlab prompt:\n');
fprintf('cd "%s"\n', dir);
fprintf('mex tinyxml2_tethys.cpp tinyxml2.cpp\n')

error('Matlb executable is not compiled');
