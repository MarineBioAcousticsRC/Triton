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
elseif strcmp(action,'flacfolder') || strcmp(action,'unflacfolder')
  % The pointer is set only while the folders are being chosen and the job is
  % worked out. A conversion run can last hours and the loadbar is the progress
  % indicator for that -- leaving the cursor as a watch the whole time would
  % just look like Triton had hung.
  %
  % try/catch because the branches around this one have none, and an error in a
  % long folder run would otherwise strand the cursor as a watch with no way
  % back short of restarting Triton.
  set(HANDLES.fig.ctrl, 'Pointer', 'watch');
  set(HANDLES.fig.main, 'Pointer', 'watch');
  set(HANDLES.fig.msg,  'Pointer', 'watch');
  if strcmp(action,'flacfolder'); dirn = 'compress'; else; dirn = 'expand'; end
  try
    xwav_convert_gui(dirn)
  catch e
    disp_msg(['Folder conversion failed: ' e.message])
  end
  set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
  set(HANDLES.fig.main, 'Pointer', 'arrow');
  set(HANDLES.fig.msg,  'Pointer', 'arrow');

elseif strcmp(action,'mkltsa')
  set(HANDLES.fig.ctrl, 'Pointer', 'watch');
  set(HANDLES.fig.main, 'Pointer', 'watch');
  set(HANDLES.fig.msg, 'Pointer', 'watch');
  mk_ltsa
  set(HANDLES.fig.ctrl, 'Pointer', 'arrow');
  set(HANDLES.fig.main, 'Pointer', 'arrow');
  set(HANDLES.fig.msg, 'Pointer', 'arrow');
end