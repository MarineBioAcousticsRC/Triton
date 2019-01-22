function toolpd(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% toolpd.m
%
% Tools pull-down menu operation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS DATA


% converts a HARP ftp file to xwav
if strcmp(action,'convertfile')
  set(HANDLES.fig.ctrl, 'Pointer', 'watch');
  set(HANDLES.fig.main, 'Pointer', 'watch');
  set(HANDLES.fig.msg, 'Pointer', 'watch');
  hrp2xwav
  set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
  set(HANDLES.fig.main, 'Pointer', 'arrow');
  set(HANDLES.fig.msg, 'Pointer', 'arrow');
  
elseif strcmp(action,'loadTF')
    [fname, path] = uigetfile('*.tf','Load Transfer Function File');
    % if canceled button pushed:
    if strcmp(num2str(fname),'0')
        return
    end
    filename = fullfile(path, fname);
    if ~ exist(filename)
        disp_msg(sprintf('Transfer Function File %s does not exist', filename));
    else
        loadTF(filename);
        disp_msg(sprintf('Loaded Transfer Function File: %s', filename));
    end  
    
  % dialog box decimatefile into a file
elseif strcmp(action,'decimatefile')
  set(HANDLES.fig.ctrl, 'Pointer', 'watch');
  set(HANDLES.fig.main, 'Pointer', 'watch');
  set(HANDLES.fig.msg, 'Pointer', 'watch');
  decimatewav('x.wav')
  set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
  set(HANDLES.fig.main, 'Pointer', 'arrow');
  set(HANDLES.fig.msg, 'Pointer', 'arrow');
  
  % dialog box decimatefile into a file
elseif strcmp(action,'decimatefiledir')
  set(HANDLES.fig.ctrl, 'Pointer', 'watch');
  set(HANDLES.fig.main, 'Pointer', 'watch');
  set(HANDLES.fig.msg, 'Pointer', 'watch');
  decimatewav_dir('x.wav')
  set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
  set(HANDLES.fig.main, 'Pointer', 'arrow');
  set(HANDLES.fig.msg, 'Pointer', 'arrow');
  
  % dialog box decimatefile into a file
elseif strcmp(action,'decimatewavfile')
  set(HANDLES.fig.ctrl, 'Pointer', 'watch');
  set(HANDLES.fig.main, 'Pointer', 'watch');
  set(HANDLES.fig.msg, 'Pointer', 'watch');
  decimatewav('wav')
  set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
  set(HANDLES.fig.main, 'Pointer', 'arrow');
  set(HANDLES.fig.msg, 'Pointer', 'arrow');
  
  % dialog box decimatefile into a file
elseif strcmp(action,'decimatewavfiledir')
  set(HANDLES.fig.ctrl, 'Pointer', 'watch');
  set(HANDLES.fig.main, 'Pointer', 'watch');
  set(HANDLES.fig.msg, 'Pointer', 'watch');
  decimatewav_dir('wav')
  set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
  set(HANDLES.fig.main, 'Pointer', 'arrow');
  set(HANDLES.fig.msg, 'Pointer', 'arrow');
  
  % dialog box make ltsa file
elseif strcmp(action,'mkltsa')
  set(HANDLES.fig.ctrl, 'Pointer', 'watch');
  set(HANDLES.fig.main, 'Pointer', 'watch');
  set(HANDLES.fig.msg, 'Pointer', 'watch');
  mk_ltsa
  set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
  set(HANDLES.fig.main, 'Pointer', 'arrow');
  set(HANDLES.fig.msg, 'Pointer', 'arrow');
end