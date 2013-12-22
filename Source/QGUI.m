function varargout = QGUI(varargin)
% QGUI M-file for QGUI.fig


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @QGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @QGUI_OutputFcn, ...
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








%% QGUI Opening Function
% --- Executes just before QGUI is made visible.
function QGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Output handle
handles.output = hObject;

% Default parameters
handles.gaussian = 5;
handles.sobel = 4;

% Inputs
handles.image = varargin{1};
handles.directory = varargin{2};
handles.filename = varargin{3};
handles.edges = qedgeset(handles.image, handles.gaussian, 0, 1, 3, handles.sobel, handles.directory, handles.filename, 0);

% Show current filename on the GUI
set(handles.text_filename, 'String', handles.filename);

% Show the current edgeset
axes(handles.axes2)
thick = (handles.edges | circshift(handles.edges, 1) | circshift(handles.edges', 1)');
imshow(thick);

axes(handles.axes1)
if get(handles.checkbox_clahe, 'Value') == 1
    overim = adapthisteq(handles.image) / 1.5; overim(thick == 1) = 255; imshow(overim);
else
    overim = handles.image / 1.5; overim(thick == 1) = 255; imshow(overim);
end

% Update handles structure
guidata(hObject, handles);










%% QGUI Output Function
% --- Outputs from this function are returned to the command line.
function varargout = QGUI_OutputFcn(hObject, eventdata, handles) 

% Set output
varargout{1} = handles.output;













%% GUI Creation Function - Base / Background
% --- Executes during object creation, after setting all properties.
function qed_gui_CreateFcn(hObject, eventdata, handles)












%% Default Button Callback
% --- Executes on button press in button_default.
function button_default_Callback(hObject, eventdata, handles)

% Set parameters back to their default values
set(handles.popup_gaussian, 'Value', 5);
set(handles.editbox_sobel, 'String', '4');
set(handles.checkbox_clahe, 'Value', 0);

% Set the parameters in the handles cell array
handles.gaussian = 5;
handles.sobel = 4;

% Process image
handles.edges = qedgeset(handles.image, handles.gaussian, 0, 1, 3, handles.sobel, handles.directory, handles.filename, get(handles.checkbox_clahe, 'Value'));

% Update the handles cell array
guidata(hObject, handles);

% Update the image shown
axes(handles.axes2)
thick = (handles.edges | circshift(handles.edges, 1) | circshift(handles.edges', 1)');
imshow(thick);

axes(handles.axes1)
if get(handles.checkbox_clahe, 'Value') == 1
    overim = adapthisteq(handles.image) / 1.5; overim(thick == 1) = 255; imshow(overim);
else
    overim = handles.image / 1.5; overim(thick == 1) = 255; imshow(overim);
end













%% Gaussian Parameter Listbox Callback
% --- Executes on selection change in popup_gaussian.
function popup_gaussian_Callback(hObject, eventdata, handles)
handles.gaussian = get(hObject, 'Value');

% Process image
handles.edges = qedgeset(handles.image, handles.gaussian, 0, 1, 3, handles.sobel, handles.directory, handles.filename, get(handles.checkbox_clahe, 'Value'));

% Update the handles cell array
guidata(hObject, handles);

% Update the image shown
axes(handles.axes2);
thick = (handles.edges | circshift(handles.edges, 1) | circshift(handles.edges', 1)');
imshow(thick);

axes(handles.axes1)
if get(handles.checkbox_clahe, 'Value') == 1
    overim = adapthisteq(handles.image) / 1.5; overim(thick == 1) = 255; imshow(overim);
else
    overim = handles.image / 1.5; overim(thick == 1) = 255; imshow(overim);
end













%% Gaussian Parameter Listbox Creation
% --- Executes during object creation, after setting all properties.
function popup_gaussian_CreateFcn(hObject, eventdata, handles)
set(hObject, 'Value', 5);

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




















%% Textbox Creation
% --- Executes during object creation, after setting all properties.
function text_filename_CreateFcn(hObject, eventdata, handles)













%% Sobel Parameter Editbox Callback
function editbox_sobel_Callback(hObject, eventdata, handles)

% Set the parameter in the handles cell array
handles.sobel = str2double(get(hObject, 'String'));

% Process image
handles.edges = qedgeset(handles.image, handles.gaussian, 0, 1, 3, handles.sobel, handles.directory, handles.filename, get(handles.checkbox_clahe, 'Value'));

% Update the cell array
guidata(hObject, handles);

% Update the image shown
axes(handles.axes2);
thick = (handles.edges | circshift(handles.edges, 1) | circshift(handles.edges', 1)');
imshow(thick);

axes(handles.axes1)
if get(handles.checkbox_clahe, 'Value') == 1
    overim = adapthisteq(handles.image) / 1.5; overim(thick == 1) = 255; imshow(overim);
else
    overim = handles.image / 1.5; overim(thick == 1) = 255; imshow(overim);
end












%% Sobel Parameter Editbox Creation
% --- Executes during object creation, after setting all properties.
function editbox_sobel_CreateFcn(hObject, eventdata, handles)

% Colour
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end













%% Accept Button Callback
% --- Executes on button press in button_accept.
function button_accept_Callback(hObject, eventdata, handles)

% Process image
% handles.edges = qedgeset(handles.image, handles.gaussian, 0, 1, 3, handles.sobel, handles.filename, get(handles.checkbox_clahe, 'Value'));

% Update handles cell array
guidata(hObject, handles);

% Write the edge set to a temporary file
imwrite(handles.edges, strcat(handles.directory, '\temp.qed'), 'tif');

% Close the GUI
delete(handles.qed_gui);



















%% Reject Button Callback
% --- Executes on button press in button_reject.
function button_reject_Callback(hObject, eventdata, handles)

% Don't write a temporary file, just close the GUI
rmdir(strcat(handles.directory, '\', handles.filename, '-Files'), 's');
delete(handles.qed_gui);














%% Image
% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)

% Set current plot area
%axes(handles.axes2)
%guidata(hObject, handles);

% Zoom Toolbar
%set(hObject,'toolbar','figure');

















%% Contrast-Limited Adaptive Histograme Equalisation
% --- Executes on button press in checkbox_clahe.
function checkbox_clahe_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_clahe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Process image
handles.edges = qedgeset(handles.image, handles.gaussian, 0, 1, 3, handles.sobel, handles.directory, handles.filename, get(handles.checkbox_clahe, 'Value'));

% Update handles cell array
guidata(hObject, handles);

% Update image shown
axes(handles.axes2)
thick = (handles.edges | circshift(handles.edges, 1) | circshift(handles.edges', 1)');
imshow(thick);

axes(handles.axes1)
if get(handles.checkbox_clahe, 'Value') == 1
    overim = adapthisteq(handles.image) / 1.5; overim(thick == 1) = 255; imshow(overim);
else
    overim = handles.image / 1.5; overim(thick == 1) = 255; imshow(overim);
end












%% Static Objects

% Text Box : "Current Image is :"
% --- Executes during object creation, after setting all properties.
function text5_CreateFcn(hObject, eventdata, handles)

% --- Executes during object deletion, before destroying properties.
function text5_DeleteFcn(hObject, eventdata, handles)



% Text Box : Title
% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)

% --- Executes during object deletion, before destroying properties.
function text4_DeleteFcn(hObject, eventdata, handles)




% GUI Object
% --- Executes when qed_gui is resized.
function qed_gui_ResizeFcn(hObject, eventdata, handles)


% --------------------------------------------------------------------
function uipushtool3_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
