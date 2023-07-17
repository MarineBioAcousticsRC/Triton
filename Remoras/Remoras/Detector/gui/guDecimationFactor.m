function varargout = guDecimationFactor(varargin)
% GUDECIMATIONFACTOR M-file for guDecimationFactor.fig
%      GUDECIMATIONFACTOR, by itself, creates a new GUDECIMATIONFACTOR or raises the existing
%      singleton*.
%
%      H = GUDECIMATIONFACTOR returns the handle to a new GUDECIMATIONFACTOR or the handle to
%      the existing singleton*.
%
%      GUDECIMATIONFACTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUDECIMATIONFACTOR.M with the given input arguments.
%
%      GUDECIMATIONFACTOR('Property','Value',...) creates a new GUDECIMATIONFACTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guDecimationFactor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guDecimationFactor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guDecimationFactor

% Last Modified by GUIDE v2.5 24-Sep-2007 15:31:04

nargchk(1,Inf,nargin);

% format function name and call it
%varargin{1} = sprintf('%s.%s', mfilename, varargin{1});
if nargout
  [varargout{1:nargout}] = feval(varargin{:});
else
  feval(varargin{:});
end


% --- Executes just before guDecimationFactor is made visible.
function handles = guDecimationFactor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guDecimationFactor (see VARARGIN)

% Set up output
N_Callback(handles.(mfilename).N, eventdata, handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guDecimationFactor wait for user response (see UIRESUME)
% uiwait(handles.(mfilename).figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
N = sscanf(get(handles.(mfilename).N, 'String'), '%f');
if isempty(N)
    N = 100;
else
    N = round(N);
end
varargout{1} = N;


function N_Callback(hObject, eventdata, handles)
% hObject    handle to N (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get value and make sure it is an integer.
N = sscanf(get(hObject, 'String'), '%f');
if isempty(N)
    N = 100;
else
    N = round(N);
end
set(hObject, 'String', sprintf('%d', N));


% --- Executes during object creation, after setting all properties.
function N_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', sprintf('%d', 100));



% --- Executes during object creation, after setting all properties.
function DecimateLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DecimateLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



