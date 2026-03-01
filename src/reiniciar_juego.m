function handles = reiniciar_juego(handles)
fprintf("Evento: reiniciando juego\n");

%% RESETEAR VARIABLES DE ESTADO EN HANDLES
handles.P_J         = 0.0;  % puntuación del jugador
handles.P_C         = 0.0;  % puntuación de la casa
handles.pos_carta_1 = 1;    % puntero al mazo (primera carta)
handles.pos_ver_c   = 1;    % slot visual del jugador (empieza en 1)
handles.cartas_J_val = [];   % valores individuales de las cartas del jugador
handles.cartas_C_val = [];   % valores de cartas de la casa
handles.i           = 1;

%% SE OCULTAN LOS CONTENEDORES DE LAS CARTAS DEL JUGADOR
set(handles.PanelJ1,'Visible','off');
set(handles.PanelJ2,'Visible','off');
set(handles.PanelJ3,'Visible','off');
set(handles.PanelJ4,'Visible','off');
set(handles.PanelJ5,'Visible','off');
set(handles.PanelJ6,'Visible','off');
set(handles.PanelJ7,'Visible','off');
set(handles.PanelJ8,'Visible','off');
set(handles.PanelJ9,'Visible','off');
set(handles.PanelJ10,'Visible','off');
set(handles.PanelJ11,'Visible','off');
set(handles.PanelJ12,'Visible','off');
set(handles.PanelJ13,'Visible','off');

%% SE OCULTAN LOS CONTENEDORES DE LAS CARTAS DE LA CASA
set(handles.PanelC1,'Visible','off');
set(handles.PanelC2,'Visible','off');
set(handles.PanelC3,'Visible','off');
set(handles.PanelC4,'Visible','off');
set(handles.PanelC5,'Visible','off');
set(handles.PanelC6,'Visible','off');
set(handles.PanelC7,'Visible','off');
set(handles.PanelC8,'Visible','off');
set(handles.PanelC9,'Visible','off');
set(handles.PanelC10,'Visible','off');
set(handles.PanelC11,'Visible','off');
set(handles.PanelC12,'Visible','off');
set(handles.PanelC13,'Visible','off');

%% SE MUESTRAN LOS BOTONES DE PEDIR O PLANTARSE
set(handles.btnPlantarse,'Visible','on');
set(handles.btnPedir,'Visible','on');

%% SE OCULTA EL PANEL DE RESULTADOS
set(handles.PanelResultados,'Visible','off');