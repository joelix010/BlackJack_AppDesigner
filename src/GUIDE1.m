function varargout = GUIDE1(varargin)
% GUIDE1 MATLAB code for GUIDE1.fig
%      GUIDE1, by itself, creates a new GUIDE1 or raises the existing
%      singleton*.
%
%      H = GUIDE1 returns the handle to a new GUIDE1 or the handle to
%      the existing singleton*.
%
%      GUIDE1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDE1.M with the given input arguments.
%
%      GUIDE1('Property','Value',...) creates a new GUIDE1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIDE1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIDE1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIDE1

% Last Modified by GUIDE v2.5 21-Feb-2026 12:53:53

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIDE1_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIDE1_OutputFcn, ...
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


% --- Executes just before GUIDE1 is made visible.
function GUIDE1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIDE1 (see VARARGIN)

% Choose default command line output for GUIDE1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%CONFIGURACIÓN DE VARIALES GLOBALES PERSONALIZADAS
handles.P_J = 0.0; % PUNTUACIÓN TOTAL DEL JUGADOR
handles.cartas_J_val = []; % Valores numéricos de las cartas del jugador
guidata(hObject, handles);

handles.P_C = 0.0; % PUNTUACIÓN TOTAL DE LA CASA
handles.cartas_C_val = []; % Valores numéricos de las cartas de la casa
guidata(hObject, handles);

handles.pos_carta_1 = 1; % USAR con VARIABLES Baraja_figura y Bajara_valor
guidata(hObject, handles);

handles.total_cartas = 40; % auxiliar para el calculo de probabilidades
guidata(hObject, handles);

handles.pos_ver_c = 1; % contador para desplegar los paneles del jugador y carta
guidata(hObject, handles);

handles.i = 1;
guidata(hObject, handles);
% UIWAIT makes GUIDE1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
handles.axesJ13.Toolbar.Visible = 'off';
al_abrir_ventana(handles);

% --- Outputs from this function are returned to the command line.
function varargout = GUIDE1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1

% CONFIGURACIÓN DE FONDO DE PANTALLA
%   setBackgroundWindow(hObject);   -

%%%% SUPPORT FUNCTIONS %%%%
%% CONFIGURACION DE FONDO DE PANTALLA
% Recibe como parametro el objeto componente sobre el que se quieref
% configurar
function setBackgroundWindow(hObject)
 % 1) Que el axes cubra toda la figura
    set(hObject, 'Units','normalized', ...
                 'Position',[0 0 1 1]);

    % 2) Cargar imagen
    basePath = fileparts(mfilename('fullpath'));
    imgPath  = fullfile(basePath, './green-background1.jpg'); % cambia por tu archivo
    I = imread(imgPath);

    % 3) Dibujar imagen estirada
    image('Parent', hObject, 'CData', I);

    % Forzar que ocupe TODO el axes
    set(hObject, 'XLim', [1 size(I,2)], ...
                 'YLim', [1 size(I,1)], ...
                 'YDir', 'reverse');   % importante para que no se invierta

    % Ajuste para que se estire
    set(hObject, 'Position',[0 0 1 1]);
    axis(hObject, 'off');
    set(hObject, 'Units','normalized');

    % 4) Que no bloquee botones
    set(hObject, 'HitTest','off');
    set(findobj(hObject,'Type','image'),'HitTest','off');

    % 5) Mandar al fondo
    uistack(hObject,'bottom');


% --- Executes on button press in btnNuevoJuego.
function btnNuevoJuego_Callback(hObject, eventdata, handles)
fprintf("Has presionado el botón de 'JUEVO NUEVO'\n");

% correccion JJ de bug (boton plantarse)
set(handles.btnPedir, 'Enable', 'on');
set(handles.btnPlantarse, 'Enable', 'on');

% SE LIMPIAN LOS CONTENEDORES Y SE RESETEAN LAS VARIABLES
handles = reiniciar_juego(handles);
guidata(hObject, handles);

%SE HACE EL PROCESO DE CARGA DE BARAJA
crear_variables_baraja();
cargar_variables_baraja();

% SE BARAJEA (handles se actualiza con Baraja_fig y Baraja_val barajeadas)
handles = barajear(hObject, handles);

% SE REPARTE AL JUGADOR (2 cartas)
for k = 1:2
    carta_fig = handles.Baraja_fig{handles.pos_carta_1};
    carta_val = handles.Baraja_val(handles.pos_carta_1);
    
    handles.cartas_J_val = [handles.cartas_J_val, carta_val];
    mostrar_figuras(carta_fig, handles.pos_ver_c, 'jugador', handles);
    
    handles.pos_carta_1 = handles.pos_carta_1 + 1;
    handles.pos_ver_c   = handles.pos_ver_c   + 1;
end
handles.P_J = calcular_puntaje(handles.cartas_J_val);
guidata(hObject, handles);

% SE REPARTE A LA CASA (2 cartas)
% Carta 1 (Visible)
carta_fig_c1 = handles.Baraja_fig{handles.pos_carta_1};
carta_val_c1 = handles.Baraja_val(handles.pos_carta_1);
handles.cartas_C_val = [handles.cartas_C_val, carta_val_c1];
mostrar_figuras(carta_fig_c1, 1, 'casa', handles); % Muestra en la pos 1 de la casa
handles.pos_carta_1 = handles.pos_carta_1 + 1;

% Carta 2 (Oculta por ahora, solo la guardamos en lógicos, mostraremos el reverso)
% Asumiendo que tienes una imagen de reverso
carta_val_c2 = handles.Baraja_val(handles.pos_carta_1);
handles.cartas_C_val = [handles.cartas_C_val, carta_val_c2];
mostrar_figuras('Mazo_BlackJack/Especiales/reverso.png', 2, 'casa', handles); % Oculta en pos 2
handles.pos_carta_1 = handles.pos_carta_1 + 1;

handles.P_C = calcular_puntaje(handles.cartas_C_val);
guidata(hObject, handles);

% MOSTRAR RESULTADOS INICIALES EN UI
set(handles.PanelResultados, 'Visible', 'on');
set(handles.editResultados, 'String', sprintf('Tu puntaje: %.0f', handles.P_J));

fprintf("Puntaje inicial del jugador: %.0f\n", handles.P_J);

% Verificar si el jugador tiene Blackjack de inicio (21 exacto con 2 cartas)
if handles.P_J == 21
    set(handles.editResultados, 'String', '¡Blackjack! Turno de la casa...');
    set(handles.btnPedir, 'Enable', 'off');
    % Forzamos turno de la casa para ver si empata
    btnPlantarse_Callback(hObject, eventdata, handles);
end




% --- Executes on button press in btnSimulacion.
function btnSimulacion_Callback(hObject, eventdata, handles)

fprintf("Has presionado el boton de 'SIMULACION'\n");
simulacion;


% --- Executes on button press in btnSalir.
function btnSalir_Callback(hObject, eventdata, handles)
fprintf("Has presionado el botón de 'SALIR'\n");
figure1_CloseRequestFcn(handles.figure1, eventdata, handles)


% --- Executes on button press in btnPedir.
function btnPedir_Callback(hObject, eventdata, handles)
fprintf("Has presionado el botón de 'PEDIR MÁS CARTAS'\n");

P_J       = handles.P_J;
pos_ver_c = handles.pos_ver_c;

% Solo se puede pedir si no se ha pasado y quedan slots visuales
if (handles.P_J < 21 && pos_ver_c <= 12)

    %  Tomar siguiente carta del mazo 
    carta_fig = handles.Baraja_fig{handles.pos_carta_1};
    carta_val = handles.Baraja_val(handles.pos_carta_1);

    %  Actualizar conjunto de cartas y calcular puntuación real (Aces)
    handles.cartas_J_val = [handles.cartas_J_val, carta_val];
    handles.P_J = calcular_puntaje(handles.cartas_J_val);
    guidata(hObject, handles);

    %  Mostrar la carta en el slot visual correspondiente 
    mostrar_figuras(carta_fig, pos_ver_c, 'jugador', handles);
    fprintf("Carta pedida: %s  | P_J total: %.0f\n", carta_fig, handles.P_J);

    set(handles.PanelResultados,'Visible','on');
    set(handles.editResultados,'String', sprintf('Tu puntaje: %.0f', handles.P_J));

    %  Avanzar contadores 
    handles.pos_carta_1 = handles.pos_carta_1 + 1;
    handles.pos_ver_c   = pos_ver_c + 1;
    guidata(hObject, handles);

    %  Verificar si el jugador se pasó DESPUÉS de sumar 
    if handles.P_J > 21
        fprintf("¡El jugador se ha pasado (Bust)! P_J = %.0f\n", handles.P_J);
        set(handles.PanelResultados, 'Visible', 'on');
        set(handles.editResultados, 'String', sprintf('¡Te has pasado! (%.0f) Gana la Casa.', handles.P_J));

        set(handles.btnPedir, 'Enable', 'off');
        set(handles.btnPlantarse, 'Enable', 'off');
        
        % Opcional: revelar la carta oculta de la casa para mostrarla
        carta_oculta_fig = handles.Baraja_fig{handles.pos_carta_1 - 2}; % Reconstruir ruta asumiendo posiciones pos_carta
        mostrar_figuras(carta_oculta_fig, 2, 'casa', handles);
    elseif handles.P_J == 21
         % Auto plantarse si llega a 21
         btnPlantarse_Callback(hObject, eventdata, handles);
    end

else
    fprintf("No se puede pedir más cartas. P_J=%.1f pos=%d\n", P_J, pos_ver_c);
    set(handles.PanelResultados, 'Visible', 'on');
    set(handles.editResultados, 'String', '¡No puedes pedir más cartas!');
end



% --- Executes on button press in btnPlantarse.
function btnPlantarse_Callback(hObject, eventdata, handles)
fprintf("Has presionado el botón de 'PLANTARSE'\n");

% --- VALIDACIÓN DE SEGURIDAD ---
if handles.P_J > 21 || handles.P_J == 0
    return; % No hace nada si ya perdió o no tiene cartas
end
% Desactivar botones para que no se presione nada mientras la casa juega
set(handles.btnPedir, 'Enable', 'off');
set(handles.btnPlantarse, 'Enable', 'off');
% -------------------------------

% El jugador se planta
fprintf("El jugador se planta con P_J = %.0f\n", handles.P_J);
set(handles.PanelResultados, 'Visible', 'on');
set(handles.editResultados, 'String', sprintf('Te plantaste con %.0f. Turno de la casa...', handles.P_J));

% REVELAR LA CARTA OCULTA DE LA CASA (Asumiendo que es la segunda carta repartida)
% Tenemos que reconstruir cuál fue la imagen. Las repartimos hace unos turnos.
% Como la casa solo tiene 2 cartas en este punto, miramos en Baraja_fig.
% La carta 1 de la casa estuvo en (pos_inicial_casa), la 2 en (pos_inicial_casa + 1)
% Como no guardamos la ruta en el array `cartas_C_val`, vamos a buscar la carta en Baraja_val que coincida... o mejor, dado que Baraja no cambia de orden post-barajeo:
% La casa recibió cartas en los índices 3 y 4 absolutos del juego inicial.
% Así que la carta oculta es la de índice absoluto 4 del mazo.
idx_carta2_casa = 4;
carta_fig_c2 = handles.Baraja_fig{idx_carta2_casa};
mostrar_figuras(carta_fig_c2, 2, 'casa', handles);

drawnow;
pause(1.0);

% BUCLE COMPLETO DE LA CASA   
handles = juega_casa(hObject, handles);
function editResultados_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function editResultados_CreateFcn(hObject, eventdata, handles)


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axesJ13_CreateFcn(hObject, eventdata, handles)
handles.axesJ13.Toolbar.Visible = 'off';


% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
fprintf("Se ha cerrado la ventana con éxito\n");
