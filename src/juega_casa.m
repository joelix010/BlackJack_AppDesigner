function handles = juega_casa(hObject, handles)
    fprintf("----------------------------------------------------------------------------\n");
    fprintf("Es el turno de la casa...\n");
    fprintf("La casa empieza con %.2f (ya tiene su primera carta y revelará la segunda)\n\n", handles.P_C);

    % Slot visual de la casa (pos 1 y 2 ya fueron usadas en el reparto inicial)
    pos_ver_c_casa = 3;

    % BUCLE DE TURNO DE LA CASA: Estrategia del Valor Objetivo (>= 17)
    while true
        % Evaluar puntaje actual de la casa
        handles.P_C = calcular_puntaje(handles.cartas_C_val);
        
        % Mostrar estado
        fprintf("Puntaje actual de la casa: %.2f\n", handles.P_C);
        
        % Condición de parada obligatoria: >= 17
        if handles.P_C >= 17
            fprintf("La casa debe plantarse con %.2f puntos.\n", handles.P_C);
            break;
        end

        % La casa pide una carta mas
        fprintf("La casa tiene menos de 17, está obligada a pedir otra carta...\n");

        carta_fig = handles.Baraja_fig{handles.pos_carta_1};
        carta_val = handles.Baraja_val(handles.pos_carta_1);

        % Añadir la nueva carta al conjunto de la casa
        handles.cartas_C_val = [handles.cartas_C_val, carta_val];
        handles.pos_carta_1 = handles.pos_carta_1 + 1;
        handles.P_C = calcular_puntaje(handles.cartas_C_val); % Recalcular con la nueva carta
        
        guidata(hObject, handles);

        % Mostrar carta en la GUI (slots C2, C3, ...)
        if pos_ver_c_casa <= 12
            mostrar_figuras(carta_fig, pos_ver_c_casa, 'casa', handles);
            pos_ver_c_casa = pos_ver_c_casa + 1;
        end

        % PAUSA POR CADA CARTA EXTRA
        % ==========================================================
        drawnow;    % Refresca la interfaz visual
        pause(1.0); % Pausa de 1 segundo entre cada carta nueva
        % ==========================================================

        fprintf("Casa recibe carta: %s (valor: %.1f) | P_C total: %.2f\n", ...
                carta_fig, carta_val, handles.P_C);

        % ¿Se pasó la casa? 
        if handles.P_C > 21
            fprintf("\nLa casa se paso con %.2f (Bust). ¡El jugador gana!\n", handles.P_C);
            set(handles.PanelResultados, 'Visible', 'on');
            set(handles.editResultados, 'String', ...
                sprintf('¡Ganaste! La casa se pasó (%.1f vs tu %.1f)', handles.P_C, handles.P_J));
            return;
        end
    end

    % DETERMINAR GANADOR FINAL
    handles = determinar_ganador_gui(hObject, handles);
end


%  determinar y mostrar el ganador en la GUI
function handles = determinar_ganador_gui(hObject, handles)
    P_J = handles.P_J;
    P_C = handles.P_C;

    set(handles.PanelResultados, 'Visible', 'on');

    if P_C > 21 || P_J > P_C
        msg = sprintf('¡Ganaste! (%.1f vs casa %.1f)', P_J, P_C);
        fprintf("¡El jugador gana! (%.2f vs %.2f)\n", P_J, P_C);
    elseif P_C > P_J
        msg = sprintf('¡Gana la Casa! (%.1f vs tu %.1f)', P_C, P_J);
        fprintf("La casa ha ganado. (%.2f vs %.2f)\n", P_C, P_J);
    else
        % En Blackjack un empate es un 'Push' (empate real, a veces se devuelve el dinero)
        msg = sprintf('Empate a %.1f puntos (Push).', P_C);
        fprintf("Empate %.2f - Push.\n", P_C);
    end

    set(handles.editResultados, 'String', msg);
    guidata(hObject, handles);
end
