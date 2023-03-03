function template = getEffortTemplate()
% Return the name of the detection effort template.

RootDir = fileparts(which('triton'));
template = fullfile(RootDir, 'Remoras', 'Logger', 'log_data', 'Detection_Effort_Template.xlsx');
