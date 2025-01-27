function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 26-Nov-2017 18:26:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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

% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in list.
function list_Callback(hObject, eventdata, handles)
% hObject    handle to list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list

% --- Executes during object creation, after setting all properties.
function list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in loadFile.
function loadFile_Callback(hObject, eventdata, handles)
% hObject    handle to loadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Use:
% When load file button is pressed this will open up user interface
% to select a file. Once selected the Name of the file and the Path will be saved.
% Then we concatenate the PathName and the name of the file and save it to
% a variable called FileName


%Lauch get file gui;
[FileName,PathName] = uigetfile({'*.mat','All Files'},'Select File','MultiSelect','on');
sameChan = 1; %At first we suppose EEG file(s) have same number of channels
numberOfEEG = 0;
textLabel = '';
set(findobj('Tag','feedback'), 'String', textLabel); 
evalin('base','clear coherence_prp dpli_prp pli_prp graph_prp pac_prp spectopo_prp ste_prp');

%Need to uncheck all the checkboxes
set(findobj('Tag','Spectopomap'), 'Value',0);
set(findobj('Tag','phase_amplitude'), 'Value',0);
set(findobj('Tag','coherence'), 'Value',0);
set(findobj('Tag','pli'), 'Value',0);
set(findobj('Tag','dpli'), 'Value',0);
set(findobj('Tag','symbolic'), 'Value',0);
set(findobj('Tag','graph'), 'Value',0);

%Check if there is more than one file
if iscell(FileName) == 0
    input = num2str(FileName); %Here we make sure something was selected
    if strcmp(input,'0') == 1
        assignin('base', 'fileName', 'no file');
        evalin('base','clear numberOfEEG sameChan EEG');
        
        set(findobj('Tag','fileName'),'String','No Data');
        evalin('base','clc');
        return
    else
        set(findobj('Tag','fileName'),'String',FileName);
        assignin('base', 'fileName', [PathName FileName]);
        assignin('base','sameChan',1); %Same channel is = 1 if 1 file loaded
        
        numberOfEEG = 1;
        assignin('base', 'numberOfEEG',numberOfEEG);
        
        display('Loading EEG data...');
        EEG = load_eeg([PathName FileName]);
        assignin('base','EEG',EEG);
        
        sets_data{1} = struct('setname',EEG.setname,'filename',EEG.filename,...
        'nbchan',EEG.nbchan,'srate',EEG.srate,'xmin',EEG.xmin,'xmax',EEG.xmax);
        assignin('base','sets_data',sets_data);
        display('Loading completed!');
    end
    
else 
    %Here we go through all files and check if they have the same number of
    %channels and the same sampling rate
    display('Loading EEG data...');
    display('Counting channels and checking sampling rates:')
    for i=1:length(FileName)
        numberOfEEG = numberOfEEG + 1;
        filename{i} = [PathName FileName{i}];
        if(i == 1)
             EEG = load_eeg(filename{1});
             assignin('base','EEG',EEG);
        else
             load(filename{i});
        end
        sets_data{i} = struct('setname',EEG.setname,'filename',EEG.filename,...
        'nbchan',EEG.nbchan,'srate',EEG.srate,'xmin',EEG.xmin,'xmax',EEG.xmax);
        display(sprintf('%d/%d',i,length(FileName)));
        if i == 1
            nbchannels = EEG.nbchan;
            samplingRate = EEG.srate;
        else
            if samplingRate ~= EEG.srate 
                textLabel = sprintf('The EEG data you loaded do not have the same sampling rate. Please analyse the EEG data one at a time.');
                set(findobj('Tag','feedback'), 'String', textLabel); 
                return
            end
        end
        display('Loading completed!');
    end
    assignin('base','sets_data',sets_data);
    %save sameChan variable to workspace
    if sameChan == 1
        assignin('base','sameChan',1); %if 1 file or same number of channels set this to 1
    else
        assignin('base','sameChan',0); % else set this to 0 (disable reordering)
    end
    
    set(findobj('Tag','fileName'),'String',['Multiple EEG Files']);
    assignin('base', 'fileName', filename);
    
    assignin('base', 'numberOfEEG',numberOfEEG);
end
    assignin('base','continue_load',0);    
    %-------------RUN THE POP UP------------------
    InterfaceObj=findobj(gcf,'Enable','on');
    set(InterfaceObj,'Enable','off');%disable the main window
    run('loadWindow.m');
    uiwait(gcf); %wait for it
        
    set(InterfaceObj,'Enable','on');
    %---------------------------------------------
    continue_load = evalin('base','continue_load');
    
    if(continue_load == 0)
        set(findobj('Tag','fileName'),'String','No Data');
        set(findobj('Tag','feedback'), 'String', '');
        assignin('base', 'fileName', 'no file');
        evalin('base','clear EEG sameChan');
    end
    evalin('base','clear continue_load numberOfEEG visualize_data sets_data');
    evalin('base','clc');

% --- Executes on button press in launch.
function launch_Callback(hObject, eventdata, handles)
% hObject    handle to launch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
InterfaceObj=findobj(gcf,'Enable','on');
set(InterfaceObj,'Enable','off');
evalin('base','clc');
textLabel = '';
set(findobj('Tag','feedback'), 'String', textLabel); 


%We load spectopo , fileName and working directory
spectopomap = get(findobj('Tag','Spectopomap'),'Value');
fileNameLoad = evalin('base','fileName');
workingDirectory = lower(evalin('base','workingDirectory'));

%Here we run check to see if we can continue
check_data = get(findobj('Tag','check_data'),'Value');
if iscell(fileNameLoad) == 0
    fileName = fileNameLoad;
    if strcmp(fileName,'no file') == 1 || strcmp(workingDirectory,'no directory') == 1
        textLabel = sprintf('Please make sure you loaded EEG data, selected a saving directory and at least one analysis technique');
        set(findobj('Tag','feedback'), 'String', textLabel); 
        set(InterfaceObj,'Enable','on');
        return
    elseif check_data == 1 && spectopomap == 0
        textLabel = sprintf('Please uncheck the "check data" radio button or select spectrogram and topographic map in order to check the data.');
        set(findobj('Tag','feedback'), 'String', textLabel); 
        set(InterfaceObj,'Enable','on');
        return
    end
    numbFiles = 1;
else
    if strcmp(workingDirectory,'no directory') == 1
        textLabel = sprintf('Please make sure you selected a saving directory and at least one analysis technique');
        set(findobj('Tag','feedback'), 'String', textLabel);
        set(InterfaceObj,'Enable','on');
        return
    elseif check_data == 1 && spectopomap == 0
        textLabel = sprintf('Please uncheck the "check data" radio button or select spectrogram and topographic map in order to check the data.');
        set(findobj('Tag','feedback'), 'String', textLabel); 
        set(InterfaceObj,'Enable','on');
        return       
    end
    numbFiles = length(fileNameLoad);
end

%The pipeline will run through all file one by one and will do all analysis
%for one EEG file before starting the other one
for iteration = 1:numbFiles
    %Clear previous filename and load another
    if iscell(fileNameLoad) == 1
        clear('fileName');
        fileName = fileNameLoad{iteration};
    end
    
    if(iteration > 1)
        EEG = load_eeg(fileName); 
    else
        EEG = evalin('base','EEG');
    end
    
    display(sprintf('Analyzing: %s',EEG.filename));
    subset = evalin('base','subset');
    if(strcmp(subset,'custom') == 1)
        EEGOrderString =  evalin('base','channelSubset');
        EEGOrderString = strsplit(EEGOrderString);
        display('EEGorder string')
        display(EEGOrderString);
        labels = {EEG.chanlocs.labels}.';
        index = 1;

        for i=1:length(EEGOrderString)
           location = 0;
           for j=1:EEG.nbchan
               EEGOrderString{i}
               labels{j}
               if(strcmp(EEGOrderString{i},labels{j}) == 1)
                   location  = j;
                   break;
               end
           end
           if(location ~= 0)
            new_data(index,:) = EEG.data(location,:);
            new_chanlocs(index,:) = EEG.chanlocs(:,location);
            index = index + 1;
           end
        end
        EEG.data = new_data;
        EEG.chanlocs = new_chanlocs;
        EEG.nbchan = index - 1;
        clearvars new_data new_chanlocs
    end
    %% Spectopo
    %Check if spectopo is selected, if yes we run it
    if spectopomap == 1
        display('Spectrogram and Topographic Map:');
        
        check_data = get(findobj('Tag','check_data'),'Value');
        isWarning = evalin('base','isWarning');
        spectopo_prp = evalin('base','spectopo_prp');
        error = spectopo_function(EEG,spectopo_prp,workingDirectory,check_data,isWarning);
        
        %Reset default properties of Matlab to counteract
        % Remove <Default>Properties from root:
        prop = get(0, 'default');
        propname = fieldnames(prop);
        for iprop = 1:length(propname)
            set(0, propname{iprop}, 'remove');
        end
        
        if(error == 1)
            warndlg('Spectrogram ran into some trouble, please click help->documentation for more information on spectrogram.','Errors')
            set(InterfaceObj,'Enable','on');
        end
        
        %This will call the popup that will abort or continue the analysis
        if check_data == 1
            run('continue_analysis.m');
            movegui(gcf,'center');
            uiwait(gcf);
        elseif check_data == 0
            assignin('base', 'continue_value', 1);
        end
        continue_value = evalin('base','continue_value');
        
        %Here we decide if we abort or continue
        if continue_value == 1
            evalin('base','clear continue_value');
        else
            evalin('base','clear continue_value');
            set(InterfaceObj,'Enable','on');
        return
        end 
    end
    %% Phase Amplitude coupling
    %Call phase amplitude function
    phase_amplitude = get(findobj('Tag','phase_amplitude'),'Value');
    if phase_amplitude == 1
        display('Phase Amplitude Coupling:');
        pac_prp = evalin('base','pac_prp');
        error = phase_amplitude_coupling_function(EEG,pac_prp,workingDirectory); 
        if(error == 1)
            set(InterfaceObj,'Enable','on');
            
            %Reset default properties of Matlab to counteract
            % Remove <Default>Properties from root:
            prop = get(0, 'default');
            propname = fieldnames(prop);
            for iprop = 1:length(propname)
                set(0, propname{iprop}, 'remove');
            end
            return 
        end
    end
    %% coherence
    %Call Coherence function
    coherence = get(findobj('Tag','coherence'),'Value');
    if coherence == 1
        display('Coherence:');
        coherence_prp = evalin('base','coherence_prp');
        error = coherence_function(EEG,coherence_prp,workingDirectory);
        if(error == 1)
            set(InterfaceObj,'Enable','on');
           return 
        end
    end
    %% pli
    %Call PLI function
    pli = get(findobj('Tag','pli'),'Value');
    if pli == 1
        display('Phase Lag Index:');
        
        pli_prp = evalin('base','pli_prp');
        orderType = evalin('base','orderType')
        if(strcmp(orderType,'custom') == 1)
            newOrder = evalin('base','newOrder'); 
        else
            newOrder = 1:EEG.nbchan;
        end
        error = pli_function(EEG,pli_prp,workingDirectory,orderType,newOrder);
        if(error == 1)
            set(InterfaceObj,'Enable','on');
            return
        end
    end
    %% dpli
    %Call the dPLI function
    dpli = get(findobj('Tag','dpli'),'Value');
    if dpli == 1 
        display('Directed Phase Lag Index:');
        dpli_prp = evalin('base','dpli_prp');
        
        orderType = evalin('base','orderType')
        if(strcmp(orderType,'custom') == 1)
            newOrder = evalin('base','newOrder'); 
        else
            newOrder = 1:EEG.nbchan;
        end
        
        error = dpli_function(EEG,dpli_prp,workingDirectory,orderType,newOrder);
        if(error == 1)
            set(InterfaceObj,'Enable','on');
            return
        end
    end
    %% symbolic Transfer Entropy
    %Call the STE function
    symbolic = get(findobj('Tag','symbolic'),'Value');
    if symbolic == 1
        display('Symbolic Transfer Entropy:');
        ste_prp = evalin('base','ste_prp');
        error = ste_function(EEG,ste_prp,workingDirectory);
        if(error == 1)
            set(InterfaceObj,'Enable','on');
            return
        end
    end
    %% graph theory
    %Call the graph theory
    graph = get(findobj('Tag','graph'),'Value');
    if graph == 1
        display('Graph Theory:')
        graph_prp = evalin('base','graph_prp');
        error = graph_theory_function(EEG,graph_prp,workingDirectory);
        if(error == 1)
            set(InterfaceObj,'Enable','on');
            return
        end
    end
    
end
set(InterfaceObj,'Enable','on');
textLabel = sprintf('Done!');
set(findobj('Tag','feedback'), 'String', textLabel); 


%Reset default properties of Matlab to counteract the effect of spectopo
% Remove <Default>Properties from root:
prop = get(0, 'default');
propname = fieldnames(prop);
for iprop = 1:length(propname)
   set(0, propname{iprop}, 'remove');
end

display('EEGapp is done');

% --- Executes on button press in documentation.
function documentation_Callback(hObject, eventdata, handles)
% hObject    handle to documentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function fileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%Set up the filename variable and the working directory variable to default
assignin('base', 'fileName', 'no file');
settings = load('settings.mat');
defaultDirectory = settings.options.savingDirectory;
if(strcmp(defaultDirectory,'no directory') == 1)
    assignin('base', 'workingDirectory', 'No directory');
else
   assignin('base','workingDirectory',defaultDirectory);
   set(findobj('Tag','wd'),'String',defaultDirectory);
end
% --- Executes on button press in check_data.
function check_data_Callback(hObject, eventdata, handles)
% hObject    handle to check_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of check_data

% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function help_tab_Callback(hObject, eventdata, handles)
% hObject    handle to help_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function documentation_menu_Callback(hObject, eventdata, handles)
% hObject    handle to documentation_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textLabel = '';
set(findobj('Tag','feedback'), 'String', textLabel); 
open('Documentation.pdf'); %This opens up the documentation

% --- Executes on button press in Spectopomap.
function Spectopomap_Callback(hObject, eventdata, handles)
% hObject    handle to Spectopomap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textLabel = '';
set(findobj('Tag','feedback'), 'String', textLabel); 

%When the radio buttons are selected the pipeline will call each program
%responsible for the data collection

fileName = evalin('base','fileName');
workingDirectory = evalin('base','workingDirectory');
if get(findobj('Tag','Spectopomap'), 'Value') == 1
    if (iscell(fileName) == 1 && strcmp(workingDirectory,'No directory') == 0) || (strcmp(fileName,'no file') == 0 && strcmp(workingDirectory,'No directory') == 0)
        InterfaceObj=findobj(gcf,'Enable','on');
        set(InterfaceObj,'Enable','off');%disable the main window
        run('Spectrogram_Topog.m');%run the spectrogram figure
        uiwait(gcf); %wait for it
        
        set(InterfaceObj,'Enable','on');
        
        %Check if the figure was closed properly
        premature_close_spectopo = evalin('base','premature_close_spectopo');
        %Clear data if it wasn't close properly
        if premature_close_spectopo == 1
            evalin('base','clear spectopo_prp');
            set(findobj('Tag','Spectopomap'), 'Value',0);
        end
        evalin('base','clear premature_close_spectopo');%remove premature_close variable
    else
        textLabel = sprintf('Please make sure you loaded at least one EEG data set and selected a saving directory.');
        set(findobj('Tag','Spectopomap'), 'Value',0);
        set(findobj('Tag','feedback'), 'String',textLabel);
    end
else
   %Clear everything that was previously inputed
   evalin('base','clear spectopo_prp');
end
% Hint: get(hObject,'Value') returns toggle state of Spectopomap

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
set(0,'DefaultFigureVisible','on');
settings = evalin('base','settings');
settings.options.custom_plot_pli = 0;
options = settings.options;
save([fileparts(which(mfilename)) '/settings.mat'],'options');
evalin('base','clear');
delete(hObject);

%Reset default properties of Matlab to counteract the effect of spectopo
% Remove <Default>Properties from root:
prop = get(0, 'default');
propname = fieldnames(prop);
for iprop = 1:length(propname)
   set(0, propname{iprop}, 'remove');
end

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% evntdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
movegui(hObject,'center');
assignin('base','orderType','default');
assignin('base','subset','default');
assignin('base','isWarning',0); %set warning to 0
movegui(hObject,'center');

settings = load('settings.mat');
assignin('base','settings',settings);
%This will set the font_size for every element
%Do this by checking if we are dealing with a mac or pc
%If its a mac we need to increase the font-size
font_size = 8.5;
if ismac()
    font_size = 10.5;
    assignin('base','font_size',font_size);
end

assignin('base','font_size',font_size);

set(findobj('Tag','uipanel1'),'FontSize',font_size)
set(findobj('Tag','set_wd'),'FontSize',font_size)
set(findobj('Tag','wd'),'FontSize',font_size)
set(findobj('Tag','loadFile'),'FontSize',font_size)
set(findobj('Tag','fileName'),'FontSize',font_size)
set(findobj('Tag','check_data'),'FontSize',font_size)
set(findobj('Tag','uipanel2'),'FontSize',font_size)
set(findobj('Tag','feedback'),'FontSize',font_size)
set(findobj('Tag','uipanel3'),'FontSize',font_size)
set(findobj('Tag','spectopo_tag'),'FontSize',font_size)
set(findobj('Tag','phase_amplitude_tag'),'FontSize',font_size)
set(findobj('Tag','coherence_tag'),'FontSize',font_size)
set(findobj('Tag','pli_tag'),'FontSize',font_size)
set(findobj('Tag','dpli_tag'),'FontSize',font_size)
set(findobj('Tag','symbolic_tag'),'FontSize',font_size)
set(findobj('Tag','graph_tag'),'FontSize',font_size)
set(findobj('Tag','launch'),'FontSize',font_size)

display('Welcome to EEGapp');
InterfaceObj=findobj(gcf,'Enable','on');
set(InterfaceObj,'Enable','off');
run('feedback.m')
uiwait(gcf); %wait for it
clc;
        
set(InterfaceObj,'Enable','on');

% --------------------------------------------------------------------
function add_custom_Callback(hObject, eventdata, handles)
% hObject    handle to add_custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in set_wd.
function set_wd_Callback(hObject, eventdata, handles)
% hObject    handle to set_wd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textLabel = '';
set(findobj('Tag','feedback'), 'String', textLabel); 
settings = evalin('base','settings');
currentOptions = settings.options;

%Launch the get dir gui
wDirectory = uigetdir('../','Select Working Directory');
input = num2str(wDirectory); %Here we make sure something was selected
if strcmp(input,'0') == 1
    wDirectory = 'No directory';
    assignin('base', 'workingDirectory',wDirectory);   
else
    assignin('base', 'workingDirectory', wDirectory);
end
currentOptions.savingDirectory = wDirectory;
settings.options = currentOptions; 
assignin('base','settings',settings);
set(findobj('Tag','wd'),'String',wDirectory);
%save([fileparts(which(mfilename)) '/settings.mat'],'settings');



% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in phase_amplitude.
function phase_amplitude_Callback(hObject, eventdata, handles)
% hObject    handle to phase_amplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of phase_amplitude

%Reset default properties of Matlab to counteract
% Remove <Default>Properties from root:
prop = get(0, 'default');
propname = fieldnames(prop);
for iprop = 1:length(propname)
    set(0, propname{iprop}, 'remove');
end

textLabel = '';
set(findobj('Tag','feedback'), 'String', textLabel); 


%When the radio buttons are selected the pipeline will call each program
%responsible for the data collection (Works the same way as spectopo
%callback)
fileName = evalin('base','fileName');
workingDirectory = evalin('base','workingDirectory');
if get(findobj('Tag','phase_amplitude'), 'Value') == 1
    if (iscell(fileName) == 1 && strcmp(workingDirectory,'No directory') == 0) || (strcmp(fileName,'no file') == 0 && strcmp(workingDirectory,'No directory') == 0)
        InterfaceObj=findobj(gcf,'Enable','on');
        set(InterfaceObj,'Enable','off');
        run('Phase_Amplitude_Coupling.m');
        uiwait(gcf);
        
        set(InterfaceObj,'Enable','on');
        premature_close_ste = evalin('base','premature_close_pac');
        
        if premature_close_ste == 1
            evalin('base','clear pac_prp');
            set(findobj('Tag','phase_amplitude'), 'Value',0);
        end
        evalin('base','clear premature_close_pac');
    else
        textLabel = sprintf('Please make sure you loaded at least one EEG data set and selected a saving directory.');
        set(findobj('Tag','phase_amplitude'), 'Value',0);
        set(findobj('Tag','feedback'), 'String',textLabel);
    end   
else
   evalin('base','clear pac_prp');
end

% --- Executes on button press in coherence.
function coherence_Callback(hObject, eventdata, handles)
% hObject    handle to coherence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of coherence
%Reset default properties of Matlab to counteract
% Remove <Default>Properties from root:
prop = get(0, 'default');
propname = fieldnames(prop);
for iprop = 1:length(propname)
    set(0, propname{iprop}, 'remove');
end

textLabel = '';
set(findobj('Tag','feedback'), 'String', textLabel); 

%When the radio buttons are selected the pipeline will call each program
%responsible for the data collection (Works the same way as spectopo
%callback)
fileName = evalin('base','fileName');
workingDirectory = evalin('base','workingDirectory');
if get(findobj('Tag','coherence'), 'Value') == 1
    if (iscell(fileName) == 1 && strcmp(workingDirectory,'No directory') == 0) || (strcmp(fileName,'no file') == 0 && strcmp(workingDirectory,'No directory') == 0)
        %call the m file
        InterfaceObj=findobj(gcf,'Enable','on');
        set(InterfaceObj,'Enable','off');
        run('coherence.m');
        uiwait(gcf);
        
        set(InterfaceObj,'Enable','on');
        
        premature_close_coherence = evalin('base','premature_close_coherence');
        if premature_close_coherence == 1
            evalin('base','clear coherence_prp');
            set(findobj('Tag','coherence'), 'Value',0);
        end
        evalin('base','clear premature_close_coherence');

    else
        textLabel = sprintf('Please make sure you loaded at least one EEG data set and selected a saving directory.');
        set(findobj('Tag','coherence'), 'Value',0);
        set(findobj('Tag','feedback'), 'String',textLabel);
    end   
else
        %clear all
        evalin('base','clear coherence_prp');
end

% --- Executes on button press in pli.
function pli_Callback(hObject, eventdata, handles)
% hObject    handle to pli (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        
%Reset default properties of Matlab to counteract
% Remove <Default>Properties from root:
prop = get(0, 'default');
propname = fieldnames(prop);
for iprop = 1:length(propname)
    set(0, propname{iprop}, 'remove');
end

textLabel = '';
set(findobj('Tag','feedback'), 'String', textLabel); 


%When the radio buttons are selected the pipeline will call each program
%responsible for the data collection (Works the same way as spectopo
%callback)

% Hint: get(hObject,'Value') returns toggle state of pli
fileName = evalin('base','fileName');
workingDirectory = evalin('base','workingDirectory');
if get(findobj('Tag','pli'), 'Value') == 1
    if (iscell(fileName) == 1 && strcmp(workingDirectory,'No directory') == 0) || (strcmp(fileName,'no file') == 0 && strcmp(workingDirectory,'No directory') == 0)
        
        InterfaceObj=findobj(gcf,'Enable','on');
        set(InterfaceObj,'Enable','off');
        run('Phase_lag_index.m');
        uiwait(gcf);
        
        set(InterfaceObj,'Enable','on');
        
        premature_close_pli = evalin('base','premature_close_pli');
        if premature_close_pli == 1
            evalin('base','clear pli_prp');
            set(findobj('Tag','pli'), 'Value',0);
        end
        evalin('base','clear premature_close_pli');
    else
        textLabel = sprintf('Please make sure you loaded at least one EEG data set and selected a saving directory.');
        set(findobj('Tag','pli'), 'Value',0);
        set(findobj('Tag','feedback'), 'String',textLabel);
    end
else
   evalin('base','clear pli_prp');
end

% --- Executes on button press in dpli.
function dpli_Callback(hObject, eventdata, handles)
% hObject    handle to dpli (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of dpli

%Reset default properties of Matlab to counteract
% Remove <Default>Properties from root:
prop = get(0, 'default');
propname = fieldnames(prop);
for iprop = 1:length(propname)
    set(0, propname{iprop}, 'remove');
end

textLabel = '';
set(findobj('Tag','feedback'), 'String', textLabel); 


%When the radio buttons are selected the pipeline will call each program
%responsible for the data collection (Works the same way as spectopo
%callback)

fileName = evalin('base','fileName');
workingDirectory = evalin('base','workingDirectory');
if get(findobj('Tag','dpli'), 'Value') == 1
    if (iscell(fileName) == 1 && strcmp(workingDirectory,'No directory') == 0) || (strcmp(fileName,'no file') == 0 && strcmp(workingDirectory,'No directory') == 0)
        
        InterfaceObj=findobj(gcf,'Enable','on');
        set(InterfaceObj,'Enable','off');
        run('Directed_Phase_Lag_Index.m');
        uiwait(gcf);
        
        set(InterfaceObj,'Enable','on');
        premature_close_dpli = evalin('base','premature_close_dpli');
        if premature_close_dpli == 1
            evalin('base','clear dpli_prp');
            set(findobj('Tag','dpli'), 'Value',0);
        end
        evalin('base','clear premature_close_dpli');
    else
        textLabel = sprintf('Please make sure you loaded at least one EEG data set and selected a saving directory.');
        set(findobj('Tag','dpli'), 'Value',0);
        set(findobj('Tag','feedback'), 'String',textLabel);
    end
else
   evalin('base','clear dpli_prp');
end

% --- Executes on button press in symbolic.
function symbolic_Callback(hObject, eventdata, handles)
% hObject    handle to symbolic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of symbolic

%Reset default properties of Matlab to counteract
% Remove <Default>Properties from root:
prop = get(0, 'default');
propname = fieldnames(prop);
for iprop = 1:length(propname)
    set(0, propname{iprop}, 'remove');
end

textLabel = '';
set(findobj('Tag','feedback'), 'String', textLabel); 


%When the radio buttons are selected the pipeline will call each program
%responsible for the data collection (Works the same way as spectopo
%callback)
fileName = evalin('base','fileName');
workingDirectory = evalin('base','workingDirectory');
if get(findobj('Tag','symbolic'), 'Value') == 1
    if (iscell(fileName) == 1 && strcmp(workingDirectory,'No directory') == 0) || (strcmp(fileName,'no file') == 0 && strcmp(workingDirectory,'No directory') == 0)

        InterfaceObj=findobj(gcf,'Enable','on');
        set(InterfaceObj,'Enable','off');
        run('symbolicTransferEntropy.m');
        uiwait(gcf);
        
        set(InterfaceObj,'Enable','on');
        premature_close_ste = evalin('base','premature_close_ste');
        
        if premature_close_ste == 1
            evalin('base','clear ste_prp');
            set(findobj('Tag','symbolic'), 'Value',0);
        end
        evalin('base','clear premature_close_ste');        
    else
        textLabel = sprintf('Please make sure you loaded at least one EEG data set and selected a saving directory.');
        set(findobj('Tag','symbolic'), 'Value',0);
        set(findobj('Tag','feedback'), 'String',textLabel);
    end   
else
   evalin('base', 'clear ste_prp');
end

% --- Executes on button press in graph.
function graph_Callback(hObject, eventdata, handles)
% hObject    handle to graph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of graph

%Reset default properties of Matlab to counteract
% Remove <Default>Properties from root:
prop = get(0, 'default');
propname = fieldnames(prop);
for iprop = 1:length(propname)
    set(0, propname{iprop}, 'remove');
end

textLabel = '';
set(findobj('Tag','feedback'), 'String', textLabel); 


%When the radio buttons are selected the pipeline will call each program
%responsible for the data collection (Works the same way as spectopo
%callback)
fileName = evalin('base','fileName');
workingDirectory = evalin('base','workingDirectory');
if get(findobj('Tag','graph'), 'Value') == 1
    if (iscell(fileName) == 1 && strcmp(workingDirectory,'No directory') == 0) || (strcmp(fileName,'no file') == 0 && strcmp(workingDirectory,'No directory') == 0)

        InterfaceObj=findobj(gcf,'Enable','on');
        set(InterfaceObj,'Enable','off');
        run('GraphTheory.m');
        uiwait(gcf);
        
        set(InterfaceObj,'Enable','on');
        
        premature_close_graph = evalin('base','premature_close_graph');
        if premature_close_graph == 1
            evalin('base','clear graph_prp');
            set(findobj('Tag','graph'), 'Value',0);
        end
        evalin('base','clear premature_close_graph');
    else
        textLabel = sprintf('Please make sure you loaded at least one EEG data set and selected a saving directory.');
        set(findobj('Tag','graph'), 'Value',0);
        set(findobj('Tag','feedback'), 'String',textLabel);
    end   
else
   evalin('base','clear graph_prp');
end

% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function quit_Callback(hObject, eventdata, handles)
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close();


% --------------------------------------------------------------------
function option_Callback(hObject, eventdata, handles)
% hObject    handle to option (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function set_bp_Callback(hObject, eventdata, handles)
% hObject    handle to set_bp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
InterfaceObj=findobj(gcf,'Enable','on');
set(InterfaceObj,'Enable','off');
run('bandpass_settings.m');
uiwait(gcf);        
set(InterfaceObj,'Enable','on');


% --------------------------------------------------------------------
function Select_channels_Callback(hObject, eventdata, handles)
% hObject    handle to Select_channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileName = evalin('base','fileName');
workingDirectory = evalin('base','workingDirectory');
    if (iscell(fileName) == 1 && strcmp(workingDirectory,'No directory') == 0) || (strcmp(fileName,'no file') == 0 && strcmp(workingDirectory,'No directory') == 0) 
        InterfaceObj=findobj(gcf,'Enable','on');
        set(InterfaceObj,'Enable','off');%disabling the current window
        run('select_channels.m'); %running the program (Reorder)
        uiwait(gcf); %wait for it to be done

        set(InterfaceObj,'Enable','on');%re-enabling the window
    else
        textLabel = sprintf('Please make sure you loaded at least one EEG data set and selected a saving directory.');
        set(findobj('Tag','feedback'), 'String',textLabel);
    end