function varargout = guConfirmComponent(varargin)
% guConfirmComponent M-file for guConfirmComponent.fig
% Reusable component.
% Use with guComponentLoad to add okay/cancel buttons to dialog.
% 
% Once all components have been loaded, execute component user should
% execute uiwait(handles.ContainingFig) which will cause the GUI
% to wait until Okay/Cancel, or the close box are selected.
%
% Caveat: If the close box is selected, all handles will become invalid.
% Consequently, users wishing to use dialogs with close buttons should be
% prepared to test the validity of at least one of the handles before using
% them.
%
% Sample usage:
%       Set up:
%       handles.ContainingFig = figure('Name', 'Tweedle Dee', ...
%               'Toolbar', 'None', 'MenuBar', 'none', 'NumberTitle',
%               'off');
%       handles = guComponentLoad(handles.ContainingFig [], handles, ...
%           'guConfirmComponent');
%       guComponentScale(handles.ContainingFig [], handles);
%       uiwait(handles.ContainingFig);  % block until okay/cancel/close
%
%       if ishandle(handles.ContainintFig)
%           % User pressed Okay/Cancel
%           if handles.guConfirmComponent.canceled
%               % user canceled action
%           else
%               % user okay action
%           end
%       else
%           % user close box action, remember, all handles invalid
%       end
%
% It is possible to add callbacks to test the validity of other
% components and display an error message in the Okay box.  Callbacks
% to other components should return an error string if it is not okay
% to proceed and the empty string if it is.  Assume function
% Here's an example with a nested function in humptee_dumpty.m:
%
% function humptee_dumpty
%       % open the figure and load components see guComponentLoad ...
%       % handles is now set up with all components
%       guConfirmComponent('Validity_CallbackFcn', @check_validity);
%       uiwait(handles.ContainingFig)
%
% % nested function inside humptee_dumpty
% function ErrorString = check_validity(hObject, eventdata, handles)
%       % User defined code examines various components to make
%       % sure that everything is okay.  Assume it sets valid
%       % appropriately.
%       if valid
%          ErrorString = [];
%       else
%          % If error message is larger than button, it will be
%          % truncated.
%          ErrorString = 'Informative Error Message';
%       end


nargchk(1,Inf,nargin);

% format function name and call it
%varargin{1} = sprintf('%s.%s', mfilename, varargin{1});
if nargout
  [varargout{1:nargout}] = feval(varargin{:});
else
  feval(varargin{:});
end


% --- Executes just before guConfirmComponent is made visible.
function handles = guConfirmComponent_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guConfirmComponent (see VARARGIN)

% Set up text color for valid/invalid entries
handles.(mfilename).textcolor.valid = 'black';
handles.(mfilename).textcolor.invalid = 'red';
handles.(mfilename).bgcolor.invalid = 'red';
handles.(mfilename).canceled = false;
handles.(mfilename).delay = 1.5;
handles.(mfilename).VerifyFcn = [];

% --- Outputs from this function are returned to the command line.
function varargout = guConfirmComponent_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function handles = Verify_CallbackFcn(hObject, eventdata, handles, hCallback)
handles.(mfilename).VerifyFcn = hCallback;

% --- Executes on button press in confirm.
function confirm_Callback(hObject, eventdata, handles)
% hObject    handle to confirm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

proceed = true;
if isa(handles.(mfilename).VerifyFcn, 'function_handle')
  errstr = handles.(mfilename).VerifyFcn(hObject, eventdata, handles);
  if ~ isempty(errstr)
    proceed = false;
    % Save current settings
    okaystr = get(handles.(mfilename).confirm, 'String');
    bgcolor = get(handles.(mfilename).confirm, 'BackgroundColor');
    % Display error string w/ appropriate background
    set(handles.(mfilename).confirm, 'String', errstr);
    set(handles.(mfilename).confirm, 'BackgroundColor', ...
                      handles.(mfilename).bgcolor.invalid);
    pause(handles.(mfilename).delay);   % let user read
    % Restore okay button
    set(handles.(mfilename).confirm, 'String', okaystr);
    set(handles.(mfilename).confirm, 'BackgroundColor', bgcolor);
  end
end
  
if proceed
  uiresume(handles.ContainingFig);
end


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.(mfilename).canceled = true;
guidata(hObject, handles);      % Save cancellation
uiresume(handles.ContainingFig);

