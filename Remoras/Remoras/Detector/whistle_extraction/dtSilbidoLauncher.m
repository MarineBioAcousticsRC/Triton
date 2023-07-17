function dtSilbidoLauncher(handle, event, varargin)
global PARAMS
filename = fullfile(PARAMS.inpath, PARAMS.infile);
if exist(filename) ~= 2
    errordlg('An audio file (*.wav) must be open to run Silbido')
    return
end
dtTonalAnnotate(filename, varargin{:});

