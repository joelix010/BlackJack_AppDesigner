function varargout = simulacion(varargin)
% SIMULACION MATLAB code for simulacion.fig
%      SIMULACION, by itself, creates a new SIMULACION or raises the existing
%      singleton*.
%
%      H = SIMULACION returns the handle to a new SIMULACION or the handle to
%      the existing singleton*.
%
%      SIMULACION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMULACION.M with the given input arguments.
%
%      SIMULACION('Property','Value',...) creates a new SIMULACION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before simulacion_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to simulacion_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help simulacion

% Last Modified by GUIDE v2.5 21-Feb-2026 20:51:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @simulacion_OpeningFcn, ...
                   'gui_OutputFcn',  @simulacion_OutputFcn, ...
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


% --- Executes just before simulacion is made visible.
function simulacion_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Limpiar campos de resultados
set(handles.editVecesJ, 'String', '');
set(handles.editVecesC, 'String', '');
set(handles.edit4, 'String', '');

% --- NUEVO: Actualizar las opciones de los menús desplegables ---
% Implementado para Black Jack
% Opciones para la Casa
set(handles.popupEstrategiasC, 'String', {'Valor Objetivo', 'Probabilidades'});

% Opciones para el Jugador
set(handles.popupEstrategiasJ, 'String', {'Valor Objetivo', 'Del repartidor', 'Del puntaje optimo', 'Doblar Apuesta', 'Dividir Juego'});
% ----------------------------------------------------------------

guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = simulacion_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% 
function textENumero_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function textENumero_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)


% --- Executes on button press in BtnSalir.
function BtnSalir_Callback(hObject, eventdata, handles)
delete(handles.figure1);


% --- Executes on button press in BtnEmpezar.
function BtnEmpezar_Callback(hObject, eventdata, handles)
% Leer el numero de iteraciones
num_iter = str2double(get(handles.textENumero, 'String'));
if isnan(num_iter) || num_iter <= 0
    msgbox('Error: ingresa un numero valido de iteraciones.', 'Error', 'error');
    return;
end
num_iter = round(num_iter);

% Leer las estrategias seleccionadas
estrategias_J = get(handles.popupEstrategiasJ, 'String');
idx_J = get(handles.popupEstrategiasJ, 'Value');
est_J_nombre = estrategias_J{idx_J};

estrategias_C = get(handles.popupEstrategiasC, 'String');
idx_C = get(handles.popupEstrategiasC, 'Value');
est_C_nombre = estrategias_C{idx_C};

% Mapear nombres (AQUÍ CAMBIAMOS A DOS FUNCIONES DISTINTAS)
est_J = mapear_estrategia_jugador(est_J_nombre);
est_C = mapear_estrategia_casa(est_C_nombre);

% Ejecutar la simulacion
fprintf('\nSimulando %d partidas...\n', num_iter);
resultados = montecarlo_sim(num_iter, est_J, est_C);

% Mostrar resultados en los edit text
set(handles.editVecesJ, 'String', sprintf('%d (%.1f%%)', resultados.victorias_jugador, resultados.porcentaje_jugador));
set(handles.editVecesC, 'String', sprintf('%d (%.1f%%)', resultados.victorias_casa, resultados.porcentaje_casa));
set(handles.edit4, 'String', sprintf('%d', resultados.empates));

% Dibujar histograma en el axes
cla(handles.axesGrafica);
categorias = categorical({'Jugador', 'Casa'});
categorias = reordercats(categorias, {'Jugador', 'Casa'});
datos = [resultados.victorias_jugador, resultados.victorias_casa];
colores = [0.2 0.6 0.9; 0.9 0.3 0.3];
b = bar(handles.axesGrafica, categorias, datos, 0.6);
b.FaceColor = 'flat';
b.CData = colores;
ylabel(handles.axesGrafica, 'Victorias', 'FontSize', 10);
title(handles.axesGrafica, sprintf('Resultados (%d partidas)', num_iter), 'FontSize', 12);
grid(handles.axesGrafica, 'on');
set(handles.axesGrafica, 'FontSize', 10);

fprintf('\n=== Monte Carlo: %d partidas ===\n', num_iter);
fprintf('Jugador: %.1f%% | Casa: %.1f%% (empates: %d)\n', ...
    resultados.porcentaje_jugador, resultados.porcentaje_casa, resultados.empates);
% NUEVO: Imprimir el saldo neto para ver si doblar la apuesta funcionó financieramente
fprintf('>>> SALDO NETO DEL JUGADOR: %d unidades <<<\n', resultados.saldo_neto);
% % % Leer el numero de iteraciones
% % num_iter = str2double(get(handles.textENumero, 'String'));
% % if isnan(num_iter) || num_iter <= 0
% %     msgbox('Error: ingresa un numero valido de iteraciones.', 'Error', 'error');
% %     return;
% % end
% % num_iter = round(num_iter);
% % 
% % % Leer las estrategias seleccionadas
% % estrategias_J = get(handles.popupEstrategiasJ, 'String');
% % idx_J = get(handles.popupEstrategiasJ, 'Value');
% % est_J_nombre = estrategias_J{idx_J};
% % 
% % estrategias_C = get(handles.popupEstrategiasC, 'String');
% % idx_C = get(handles.popupEstrategiasC, 'Value');
% % est_C_nombre = estrategias_C{idx_C};
% % 
% % % Mapear nombres 
% % est_J = mapear_estrategia(est_J_nombre);
% % est_C = mapear_estrategia(est_C_nombre);
% % 
% % % Ejecutar la simulacion
% % fprintf('\nSimulando %d partidas...\n', num_iter);
% % resultados = montecarlo_sim(num_iter, est_J, est_C);
% % 
% % % Mostrar resultados en los edit text
% % set(handles.editVecesJ, 'String', sprintf('%d (%.1f%%)', resultados.victorias_jugador, resultados.porcentaje_jugador));
% % set(handles.editVecesC, 'String', sprintf('%d (%.1f%%)', resultados.victorias_casa, resultados.porcentaje_casa));
% % set(handles.edit4, 'String', sprintf('%d', resultados.empates));
% % 
% % % Dibujar histograma en el axes
% % cla(handles.axesGrafica);
% % categorias = categorical({'Jugador', 'Casa'});
% % categorias = reordercats(categorias, {'Jugador', 'Casa'});
% % datos = [resultados.victorias_jugador, resultados.victorias_casa];
% % colores = [0.2 0.6 0.9; 0.9 0.3 0.3];
% % b = bar(handles.axesGrafica, categorias, datos, 0.6);
% % b.FaceColor = 'flat';
% % b.CData = colores;
% % ylabel(handles.axesGrafica, 'Victorias', 'FontSize', 10);
% % title(handles.axesGrafica, sprintf('Resultados (%d partidas)', num_iter), 'FontSize', 12);
% % grid(handles.axesGrafica, 'on');
% % set(handles.axesGrafica, 'FontSize', 10);
% % 
% % fprintf('\n=== Monte Carlo: %d partidas ===\n', num_iter);
% % fprintf('Jugador: %.1f%% | Casa: %.1f%% (empates: %d)\n', ...
% %     resultados.porcentaje_jugador, resultados.porcentaje_casa, resultados.empates);


% --- Executes on selection change in popupEstrategiasC.
function popupEstrategiasC_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popupEstrategiasC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupEstrategiasJ.
function popupEstrategiasJ_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popupEstrategiasJ_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%  mapear el nombre de estrategia del JUGADOR
function clave = mapear_estrategia_jugador(nombre)
    nombre_min = lower(strtrim(nombre));
    if contains(nombre_min, 'objetivo')
        clave = 'Valor Objetivo';
    elseif contains(nombre_min, 'repartidor')
        clave = 'Del repartidor';
    elseif contains(nombre_min, 'optimo') || contains(nombre_min, 'óptimo') || contains(nombre_min, 'básica')
        clave = 'optimo';
    elseif contains(nombre_min, 'doblar')
        clave = 'doblar_apuesta';
    elseif contains(nombre_min, 'dividir') || contains(nombre_min, 'split')
        clave = 'dividir_juego';
    else
        clave = 'optimo';  % default por seguridad
    end
%end


%  mapear el nombre de estrategia de la CASA
function clave = mapear_estrategia_casa(nombre)
    nombre_min = lower(strtrim(nombre));
    if contains(nombre_min, 'probabilidad') || contains(nombre_min, 'probabilistica')
        clave = 'probabilidad';
    else
        clave = 'valor_objetivo'; % default clásico (se planta en 17)
    end
%end

% % mapear el nombre de estrategia 
% % function clave = mapear_estrategia(nombre)
% %     switch lower(strtrim(nombre))
% %         case {'probabilidad', 'probabilistica'}
% %             clave = 'probabilistica';
% %         case 'conservadora'
% %             clave = 'conservadora';
% %         case 'moderada'
% %             clave = 'moderada';
% %         case 'arriesgada'
% %             clave = 'arriesgada';
% %         otherwise
% %             clave = 'moderada';  % default
% %     end

function editVecesC_Callback(hObject, eventdata, handles)
% hObject    handle to editVecesC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVecesC as text
%        str2double(get(hObject,'String')) returns contents of editVecesC as a double


% --- Executes during object creation, after setting all properties.
function editVecesC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVecesC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editVecesJ_Callback(hObject, eventdata, handles)
% hObject    handle to editVecesJ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVecesJ as text
%        str2double(get(hObject,'String')) returns contents of editVecesJ as a double


% --- Executes during object creation, after setting all properties.
function editVecesJ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVecesJ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end