function varargout = guGuidedSearchComponent(varargin)
% guGuidedSearchComponent M-file for guGuidedSearchComponent.fig
%      guGuidedSearchComponent, by itself, creates a new
%      guGuidedSearchComponent  or raises the existing
%      singleton*.
%
%      H = guGuidedSearchComponent returns the handle to a new
%      guGuidedSearchComponent or the handle to the existing singleton*.
%
%      guGuidedSearchComponent('CALLBACK',hObject,eventData,handles,...)
%      calls the local function named CALLBACK in guGuidedSearchComponent.m
%      with the given input arguments.
%
%      guGuidedSearchComponent('Property','Value',...) creates a new
%      guGuidedSearchComponent or raises the existing singleton*.  Starting
%      from the left, property value pairs are applied to the GUI before
%      guGuidedSearchComponent_OpeningFunction gets called.  An unrecognized
%      property name or invalid value makes property application stop.  All
%      inputs are passed to guGuidedSearchComponent_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guGuidedSearchComponent

% Last Modified by GUIDE v2.5 05-Apr-2007 13:50:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guGuidedSearchComponent_OpeningFcn, ...
                   'gui_OutputFcn',  @guGuidedSearchComponent_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before guGuidedSearchComponent is made visible.
function handles = guGuidedSearchComponent_OpeningFcn(hObject, eventdata, handles, Choices)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Choices    Specify a list of choices to be added to the default strategy.

if nargin >= 4
    % get defaults
    search = get(handles.(mfilename).SearchStrategy, 'String');
    if ~ iscell(search)
        tmp = search;   % Convert to cell
        search = cell(1,1);
        search{1} = tmp;
    end
    if min(size(Choices)) ~= 1
        error('Choices must be a vector.')
    end
    if size(Choices, 2) > 1
        Choices = Choices';  % Convert row to column
    end
    search(end+1:end+length(Choices)) = Choices;
    set(handles.(mfilename).SearchStrategy, 'String', search);
end

% --- Outputs from this function are returned to the command line.
function varargout = OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
choices = get(handles.(mfilename).SearchStrategy, 'String');
varargout{1} = choices{get(handles.(mfilename).SearchStrategy, 'Value')};


% --- Executes on selection change in SearchStrategy.
function SearchStrategy_Callback(hObject, eventdata, handles)
% hObject    handle to SearchStrategy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SearchStrategy contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SearchStrategy


% --- Executes during object creation, after setting all properties.
function handles = SearchStrategy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SearchStrategy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


