function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 23-Mar-2020 11:00:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnRunCoding.
function btnRunCoding_Callback(hObject, eventdata, handles)
% hObject    handle to btnRunCoding (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fullFileName = fullfile(handles.pathname, handles.filename);
img = dicomread(fullFileName);


[Gx, Gy] = imgradientxy(img, 'prewitt');
[Gmag, Gdir] = imgradient(Gx, Gy);



L = watershed(Gmag);
Lrgb = label2rgb(L);
%watershed thu?t toán tìm catchment basins, ridge lines, tách ??i t??ng
%kh?i background
%figure, imshow(Lrgb), title('2. Watershed transform of gradient magnitude (Lrgb)')
%STEP 4: Mark the foreground objects.

se = strel('disk', 15);
Io = imopen(img, se);
%figure
%imshow(Io, []), title('Opening (Io)')

Ie = imerode(img, se);
Iobr = imreconstruct(Ie, img);
%figure
%imshow(Iobr, []), title('Opening-by-reconstruction (Iobr)')

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr); 
%figure
%imshow(Iobrcbr, []), title('Opening-closing by reconstruction (Iobrcbr)')

fgm = imregionalmax(Iobrd); % find the regional maxima: tìm vùng c?c ??i, bi?n ??i các vùng xung quanh --> lower pixel
%figure
%imshow(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)')


se2 = strel(ones(5, 5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);
fgm4 = bwareaopen(fgm3, 0); % remove all pixel 0
I3 = img;
I3(fgm4) = 255;
%figure
%imshow(I3, [])     
%title('3. Modified regional maxima superimposed on original image (fgm4)')


%STEP 5: Mark the background objects.
bw = imbinarize(I3, 0.50100000000000000000000001);
%0.50022222211111
%0.50100000000000000000000001
%figure, imshow(bw), title('Thresholded Opening-Closing by Reconstruction');


D = bwdist(bw);
DL = watershed(D);
DL(~bw) = 0;
bgm = DL == 0;
%figure, imshow(bgm), title('4. Watershed Ridge Lines)');

%STEP 6: Estimate the watershed transform


labels = imdilate(L == 0,ones(3,3)) + 2*bgm + 3*fgm4;
I4 = labeloverlay(img,labels);
%figure, imshow(I4), title('Markers and Object Boundaries Superimposed on Original Image');

Lrgb = label2rgb(L);
%figure, imshow(Lrgb, []), title('Colored Watershed Label Matrix')

axes(handles.axes2);
%imshow(img, []);



%figure
imshow(img, [])
hold on
himage = imshow(Lrgb, []);
himage.AlphaData = 0.3;
%title('5. Colored Labels Superimposed Transparently on Original Image')



% --- Executes on button press in btnChooseImage.
function btnChooseImage_Callback(hObject, eventdata, handles)
% hObject    handle to btnChooseImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.*'});

handles.filename = filename;
handles.pathname = pathname;

fullFileName = fullfile(pathname, filename);

img = dicomread(fullFileName);

disp(filename);

axes(handles.axes1);
imshow(img, []);


guidata(hObject,handles);
