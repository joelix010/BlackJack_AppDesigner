function mostrar_figuras(carta_a_mostrar, pos, usuario, handles)

baseDir  = fileparts(mfilename('fullpath'));
rutaBase = fullfile(baseDir, '..', 'assets', 'images');

% Si carta_a_mostrar NO tiene extensión .png, viene de Baraja_fig
% (ej: 'As_de_oros') → convertir a ruta relativa (ej: 'Oros/As_de_oros.png')
if ~endsWith(carta_a_mostrar, '.png')
    carta_a_mostrar = resolver_ruta_carta(carta_a_mostrar);
end

% VERIFICACIÓN DE QUE TURNO ES:
% Si es jugador
if(strcmp(usuario, 'jugador'))
    switch pos
        % EN ESTA SECCIÓN, ESTAN LOS PANELES DEL JUGADOR
        case 1
            set(handles.PanelJ1,'Visible','on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesJ1);
        case 2
            set(handles.PanelJ2, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesJ2);
        case 3
            set(handles.PanelJ3, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesJ3);
        case 4
            set(handles.PanelJ4, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesJ4);
        case 5
            set(handles.PanelJ5, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesJ5);
        case 6
            set(handles.PanelJ6, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesJ6);
        case 7
            set(handles.PanelJ7, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesJ7);
        case 8
            set(handles.PanelJ8, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesJ8);
        case 9
            set(handles.PanelJ9, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesJ9);
        case 10
            set(handles.PanelJ10, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesJ10);
        case 11
            set(handles.PanelJ11, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesJ11);
        case 12
            set(handles.PanelJ12, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesJ12);
    end

% Si es la casa
else
    switch pos
        case 1
            set(handles.PanelC1, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesC1);
        case 2
            set(handles.PanelC2, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesC2);
        case 3
            set(handles.PanelC3, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesC3);
        case 4
            set(handles.PanelC4, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesC4);
        case 5
            set(handles.PanelC5, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesC5);
        case 6
            set(handles.PanelC6, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesC6);
        case 7
            set(handles.PanelC7, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesC7);
        case 8
            set(handles.PanelC8, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesC8);
        case 9
            set(handles.PanelC9, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesC9);
        case 10
            set(handles.PanelC10, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesC10);
        case 11
            set(handles.PanelC11, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesC11);
        case 12
            set(handles.PanelC12, 'Visible', 'on');
            imgPath = fullfile(rutaBase, carta_a_mostrar);
            img = imread(imgPath);
            imshow(img, 'Parent', handles.axesC12);
    end

end


% -------------------------------------------------------------------------
% Función auxiliar: convierte nombre de Baraja_fig a ruta relativa de imagen
%   Ejemplo: 'As_de_oros'   →  'Oros/As_de_oros.png'
%   Ejemplo: '4_de_espadas' →  'Espadas/4_de_espadas.png'
% -------------------------------------------------------------------------
function ruta = resolver_ruta_carta(nombre_carta)
    % Extraer el palo: lo que viene después del último '_de_'
    partes = strsplit(nombre_carta, '_de_');
    palo_lower = partes{end};                               % ej: 'oros'
    palo_cap   = [upper(palo_lower(1)), palo_lower(2:end)]; % ej: 'Oros'
    nombre_cap = strrep(nombre_carta, palo_lower, palo_cap); % ej: '4_de_Espadas'
    ruta = fullfile(palo_cap, [nombre_cap, '.png']);          % ej: 'Espadas/4_de_Espadas.png'
