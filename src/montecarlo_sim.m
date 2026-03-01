function resultados = montecarlo_sim(num_iteraciones, estrategia_jugador, estrategia_casa)
    
    % En lugar de solo contar victorias, llevaremos un "saldo" para que
    % estrategias como 'doblar' tengan un impacto real.
    saldo_jugador = 0;
    victorias_jugador = 0;
    victorias_casa    = 0;
    empates           = 0;

    for iter = 1:num_iteraciones
        
        % 1. Crear y barajear mazo (52 cartas para Blackjack)
        baraja_original = crear_baraja_sim();
        baraja = baraja_original(randperm(52), :);
        
        % 2. Repartir cartas iniciales (2 al jugador, 2 a la casa)
        [carta1_J, baraja] = sacar_carta_sim(baraja);
        [carta1_C, baraja] = sacar_carta_sim(baraja);
        [carta2_J, baraja] = sacar_carta_sim(baraja);
        [carta2_C, baraja] = sacar_carta_sim(baraja);
        
        cartas_J_iniciales = [carta1_J; carta2_J];
        P_J_inicial = [carta1_J(2), carta2_J(2)];
        
        cartas_C_iniciales = [carta1_C; carta2_C];
        P_C_inicial = [carta1_C(2), carta2_C(2)];
        
        % 3. Determinar multiplicador de apuesta
        multiplicador_apuesta = 1;
        if strcmp(estrategia_jugador, 'doblar_apuesta')
            % Simplificación: Asumimos que si elige la estrategia y las cartas suman 9-11, dobló.
            puntos_init = calcular_puntos(P_J_inicial);
            if puntos_init >= 9 && puntos_init <= 11
                multiplicador_apuesta = 2;
            end
        end

        % 4. Turno del Jugador
        [cartas_J_final, P_J_final, baraja, jugador_se_paso] = turno_jugador_auto(baraja, estrategia_jugador, cartas_J_iniciales, P_J_inicial, carta1_C);
        
        % --- MANEJO DE MÚLTIPLES MANOS (SPLIT) ---
        % Si el jugador no dividió, convertimos su mano en un Cell Array de 1 elemento
        % para poder usar un ciclo for uniforme y evaluar todo igual.
        if ~iscell(P_J_final)
            P_J_evaluar = {P_J_final};
            se_paso_evaluar = [jugador_se_paso];
        else
            P_J_evaluar = P_J_final; % Ya es un Cell Array con {mano1, mano2}
            se_paso_evaluar = jugador_se_paso; % Ya es un array [se_paso1, se_paso2]
        end
        
        % 5. Turno de la Casa (Solo juega si al menos una mano del jugador sobrevivió)
        todas_se_pasaron = all(se_paso_evaluar);
        
        if todas_se_pasaron
            % Si todas las manos se pasaron, la casa no necesita pedir cartas
            puntos_casa = calcular_puntos(P_C_inicial);
            casa_se_paso = false;
        else
            % La casa juega
            [puntos_casa, casa_se_paso] = turno_casa_auto(baraja, estrategia_casa, cartas_C_iniciales, P_C_inicial);
        end
        
        % 6. Comparación de resultados (iterando por cada mano del jugador)
        for m = 1:length(P_J_evaluar)
            
            if se_paso_evaluar(m)
                % Si esta mano se pasó, gana la casa
                victorias_casa = victorias_casa + 1;
                saldo_jugador = saldo_jugador - multiplicador_apuesta;
                
            elseif casa_se_paso
                % Si la casa se pasó y esta mano no, gana el jugador
                victorias_jugador = victorias_jugador + 1;
                saldo_jugador = saldo_jugador + multiplicador_apuesta;
                
            else
                % Ninguno se pasó, comparamos puntos
                puntos_mano = calcular_puntos(P_J_evaluar{m});
                
                if puntos_casa > puntos_mano
                    victorias_casa = victorias_casa + 1;
                    saldo_jugador = saldo_jugador - multiplicador_apuesta;
                elseif puntos_casa == puntos_mano
                    empates = empates + 1;
                    % En empate nadie gana ni pierde saldo (push)
                else
                    victorias_jugador = victorias_jugador + 1;
                    saldo_jugador = saldo_jugador + multiplicador_apuesta;
                end
            end
        end
        
    end

    % Armar struct de resultados (Total de manos jugadas puede ser > num_iteraciones por los splits)
    total_manos = victorias_jugador + victorias_casa + empates;
    
    resultados.victorias_jugador  = victorias_jugador;
    resultados.victorias_casa     = victorias_casa;
    resultados.empates            = empates;
    resultados.porcentaje_jugador = (victorias_jugador / max(1, total_manos)) * 100;
    resultados.porcentaje_casa    = (victorias_casa / max(1, total_manos)) * 100;
    resultados.saldo_neto         = saldo_jugador; % Indicador real de éxito
end


% calcular puntos
function puntos = calcular_puntos(valores_cartas)
    puntos = sum(valores_cartas);
    num_ases = sum(valores_cartas == 11);
    % Ajuste dinámico del As
    while puntos > 21 && num_ases > 0
        puntos = puntos - 10;
        num_ases = num_ases - 1;
    end
end

% baraja
function baraja = crear_baraja_sim()
    baraja = zeros(52, 3);
    numeros = [1, 2:10, 11, 12, 13];
    valores = [11, 2:10, 10, 10, 10];  % As=11 (calcular_puntos lo ajusta si es necesario)
    for palo = 1:4
        rango = (palo-1)*13 + 1 : palo*13;
        baraja(rango, 1) = numeros;
        baraja(rango, 2) = valores;
        baraja(rango, 3) = palo;
    end
end


% sacar carta
function [carta, baraja] = sacar_carta_sim(baraja)
    carta = baraja(1, :);
    baraja(1, :) = [];
end

% turno del jugador
function [cartas_J, P_J, baraja, se_paso] = turno_jugador_auto(baraja, estrategia, cartas_J, P_J, carta_visible_casa)
    
    % Se calcula el índice basado en las cartas que el jugador YA tiene (usualmente 2 al iniciar)
    indice = size(cartas_J, 1) + 1;
    se_paso = false;
    
    %Comienzo del Switch
    switch estrategia
        

        case 'Valor Objetivo'
            %  valor Objetivo (umbral = 17) 
            % Se pide carta hasta llegar a >= 17, luego se planta
            umbral = 17;
            puntos_J = calcular_puntos(P_J);

            % si ya supera el umbral con las 2 cartas iniciales, se planta
            if puntos_J >= umbral
                return;
            end

            while true
                [carta, baraja] = sacar_carta_sim(baraja);
                cartas_J(indice, :) = carta;
                P_J(indice) = carta(2);
                indice = indice + 1;

                puntos_J = calcular_puntos(P_J);

                if puntos_J > 21
                    se_paso = true;
                    return;
                end

                if puntos_J >= umbral
                    return;
                end
            end

        case 'Del repartidor'
             % columnas: carta del dealer [2, 3, 4, 5, 6, 7, 8, 9, Face(10), Ace(11)]

            % tabla hard (ve =valor esperado)
            ve_hard = [
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 2
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 3
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 4
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 5
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 6
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 7
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 8
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 9
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 10
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 11
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 12
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 13
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 14
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 15
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % 16
                -0.1530, -0.1172, -0.0806, -0.0449,  0.0117, -0.1068, -0.3820, -0.4232, -0.4644, -0.6386;  % 17
                 0.1217,  0.14  83,  0.1759,  0.1996,  0.2834,  0.3996,  0.1060, -0.1832, -0.2415, -0.3771;  % 18
                 0.3863,  0.4044,  0.4232,  0.4395,  0.4960,  0.6160,  0.5939,  0.2876, -0.0187, -0.1155;  % 19
                 0.6400,  0.6503,  0.6610,  0.6704,  0.7040,  0.7732,  0.7918,  0.7584,  0.4350,  0.1461;  % 20
                 0.8820,  0.8853,  0.8888,  0.8918,  0.9028,  0.9259,  0.9306,  0.9392,  0.8117,  0.3307;  % 21
            ];

            % tabla soft (ve = valor esperado)
            ve_soft = [
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % S11
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % S12
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % S13
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % S14
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % S15
                -0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.5758, -0.7694;  % S16
                -0.1530, -0.1172, -0.0806, -0.0449,  0.0117, -0.1068, -0.3820, -0.4232, -0.4644, -0.6386;  % S17
                 0.1217,  0.1483,  0.1759,  0.1996,  0.2834,  0.3996,  0.1060, -0.1832, -0.2415, -0.3771;  % S18
                 0.3863,  0.4044,  0.4232,  0.4395,  0.4960,  0.6160,  0.5939,  0.2876, -0.0187, -0.1155;  % S19
                 0.6400,  0.6503,  0.6610,  0.6704,  0.7040,  0.7732,  0.7918,  0.7584,  0.4350,  0.1461;  % S20
                 0.8820,  0.8853,  0.8888,  0.8918,  0.9028,  0.9259,  0.9306,  0.9392,  0.8117,  0.3307;  % S21
            ];

            % fila face
            ve_face = [-0.2928, -0.2523, -0.2111, -0.1672, -0.1537, -0.4754, -0.5105, -0.5431, -0.4989, -0.4617];

            % fila BJ
            ve_bj = [1.5000, 1.5000, 1.5000, 1.5000, 1.5000, 1.5000, 1.5000, 1.5000, 1.3846, 1.0385];

            % mapear carta visible de la casa a columna
            dealer_val = carta_visible_casa(2);
            if dealer_val == 11  % Ace
                col = 10;
            else
                col = dealer_val - 1;  % 2->1, 3->2, ..., 10->9
            end

            % detectar si la mano es soft (tiene un As contado como 11)
            es_soft = @(vals) any(vals == 11) & sum(vals) <= 21;

            % decision 
            while true
                puntos_J = calcular_puntos(P_J);

                if puntos_J > 21
                    break;
                end

                % buscar valor esperado en la matriz
                if es_soft(P_J)
                    % mano soft: S11-S21
                    fila_soft = puntos_J - 10;  % S11->1, S12->2, ..., S21->11
                    fila_soft = max(1, min(fila_soft, 11));
                    ve = ve_soft(fila_soft, col);
                else
                    % mano hard: 2-21
                    fila_hard = puntos_J - 1;  % 2->1, 3->2, ..., 21->20
                    fila_hard = max(1, min(fila_hard, 20));
                    ve = ve_hard(fila_hard, col);
                end

                % valor esperado positivo -> Stand, negativo -> Hit
                if ve > 0
                    return;
                end

                % Hit
                [carta, baraja] = sacar_carta_sim(baraja);
                cartas_J(indice, :) = carta;
                P_J(indice) = carta(2);
                indice = indice + 1;

                puntos_J = calcular_puntos(P_J);
                fprintf('[JUGADOR] Hit -> carta=%d, puntos=%d\n', carta(2), puntos_J);

                if puntos_J > 21
                    se_paso = true;
                    return;
                end
            end
        
        %-------- Implementacion: 3) Del puntaje Optimo (JJ)
        case 'optimo'
            % Mapeo de columna de la casa (2->Col 1, 10/Face->Col 9, As(11)->Col 10)
            val_c = carta_visible_casa(2);
            col_casa = val_c - 1; 
            if val_c == 11, col_casa = 10; end 
            
            % MATRIZ O (Diapositiva 104) - 1 = Pedir (H), 0 = Plantarse
            M_O_Dura = zeros(21, 10);
            M_O_Dura(1:11, :) = 1; % 0 a 11 siempre pide
            M_O_Dura(12, [1, 2, 6, 7, 8, 9, 10]) = 1; % Pide vs 2,3 y 7-As
            M_O_Dura(13:16, 6:10) = 1; % Pide vs 7-As
            
            M_O_Suave = zeros(21, 10);
            M_O_Suave(12:17, :) = 1; % Suave 12 a 17 siempre pide
            M_O_Suave(18, 8:10) = 1; % Suave 18 pide vs 9, Face, As
            
            while true
                puntos_J = calcular_puntos(P_J);
                if puntos_J > 21
                    se_paso = true; return;
                end
                
                ases_totales = sum(P_J == 11);
                ases_reducidos = (sum(P_J) - puntos_J) / 10;
                es_suave = (ases_totales > ases_reducidos);
                
                % Consultar la matriz de Márkov del profesor
                if es_suave
                    pedir_carta = M_O_Suave(puntos_J, col_casa);
                else
                    pedir_carta = M_O_Dura(puntos_J, col_casa);
                end
                
                if pedir_carta == 1
                    [carta, baraja] = sacar_carta_sim(baraja);
                    cartas_J(indice, :) = carta;
                    P_J(indice) = carta(2);
                    indice = indice + 1;
                else
                    return; % Se planta (espacio en blanco en diapositiva 104)
                end
            end
        % --------- Fin de implementacion 3) --------------------------
        
        %-------- Implementacion: 4) Doblar apuesta (JJ)
        case 'doblar_apuesta'
            val_c = carta_visible_casa(2);
            col_casa = val_c - 1; 
            if val_c == 11, col_casa = 10; end
            
            % MATRIZ D (Diapositiva 106) - 1 = Doblar (D), 0 = No doblar
            M_D_Dura = zeros(21, 10);
            M_D_Dura(9, 2:5) = 1;      % D vs 3,4,5,6
            M_D_Dura(10, 1:8) = 1;     % D vs 2 al 9
            M_D_Dura(11, 1:9) = 1;     % D vs 2 al Face
            
            M_D_Suave = zeros(21, 10);
            M_D_Suave(13, 4:5) = 1;    % D vs 5,6
            M_D_Suave(14, 3:5) = 1;    % D vs 4,5,6
            M_D_Suave(15, 3:4) = 1;    % D vs 4,5
            M_D_Suave(16, 3:5) = 1;    % D vs 4,5,6
            M_D_Suave(17:18, 2:5) = 1; % D vs 3,4,5,6
            
            puntos_J = calcular_puntos(P_J);
            ases_totales = sum(P_J == 11);
            ases_reducidos = (sum(P_J) - puntos_J) / 10;
            es_suave = (ases_totales > ases_reducidos);
            
            doblar = 0;
            if length(P_J) == 2 % Solo se permite doblar con 2 cartas iniciales
                if es_suave
                    doblar = M_D_Suave(puntos_J, col_casa);
                else
                    doblar = M_D_Dura(puntos_J, col_casa);
                end
            end
            
            if doblar == 1
                [carta, baraja] = sacar_carta_sim(baraja);
                cartas_J(indice, :) = carta;
                P_J(indice) = carta(2);
                if calcular_puntos(P_J) > 21
                    se_paso = true;
                end
                return; % Termina el turno forzosamente
            else
                % Si la matriz dice H (pedir) o en blanco (plantarse), delegamos a la matriz O
                [cartas_J, P_J, baraja, se_paso] = turno_jugador_auto(baraja, 'optimo', cartas_J, P_J, carta_visible_casa);
                return;
            end
        % --------- Fin de implementacion 4) --------------------------
        
        %-------- Implementacion: 5) Dividir Juego (JJ)
        case 'dividir_juego'
            val_c = carta_visible_casa(2);
            col_casa = val_c - 1; 
            if val_c == 11, col_casa = 10; end
            
            % MATRIZ S (Diapositiva 108) - 1 = Dividir (S), 0 = No dividir
            M_S = zeros(11, 10);
            M_S(2:3, 1:6) = 1;       % Pares de 2 y 3: S vs 2 al 7
            M_S(4, 4:5) = 1;         % Pares de 4: S vs 5,6
            M_S(6, 1:5) = 1;         % Pares de 6: S vs 2 al 6
            M_S(7, 1:6) = 1;         % Pares de 7: S vs 2 al 7
            M_S(8, 1:8) = 1;         % Pares de 8: S vs 2 al 9
            M_S(9, [1,2,3,4,5,7,8]) = 1; % Pares de 9: S vs 2-6 y 8-9
            M_S(11, :) = 1;          % Pares de Ases: S vs Todos
            
            dividir = 0;
            if length(P_J) == 2 && P_J(1) == P_J(2)
                carta_par = P_J(1);
                dividir = M_S(carta_par, col_casa);
            end
                
            if dividir == 1
                mano1_cartas = cartas_J(1, :);
                mano1_P = P_J(1);
                mano2_cartas = cartas_J(2, :);
                mano2_P = P_J(2);
                
                % MANO 1
                [carta_nueva1, baraja] = sacar_carta_sim(baraja);
                mano1_cartas = [mano1_cartas; carta_nueva1];
                mano1_P = [mano1_P, carta_nueva1(2)];
                [mano1_cartas, mano1_P, baraja, se_paso1] = turno_jugador_auto(baraja, 'optimo', mano1_cartas, mano1_P, carta_visible_casa);
                
                % MANO 2
                [carta_nueva2, baraja] = sacar_carta_sim(baraja);
                mano2_cartas = [mano2_cartas; carta_nueva2];
                mano2_P = [mano2_P, carta_nueva2(2)];
                [mano2_cartas, mano2_P, baraja, se_paso2] = turno_jugador_auto(baraja, 'optimo', mano2_cartas, mano2_P, carta_visible_casa);
                
                cartas_J = {mano1_cartas, mano2_cartas};
                P_J = {mano1_P, mano2_P};
                se_paso = [se_paso1, se_paso2];
                return;
            else
                % Si no son pares o la matriz está en blanco, delegamos a la matriz O
                [cartas_J, P_J, baraja, se_paso] = turno_jugador_auto(baraja, 'optimo', cartas_J, P_J, carta_visible_casa);
                return;
            end
        % --------- Fin de implementacion 5) --------------------------
            
    end
    %Final del Switch

end

% >>> TURNO DE LA CASA <<<
% Completamente reescrito para Blackjack
function [puntos_casa, se_paso] = turno_casa_auto(baraja, estrategia, cartas_C, P_C)
    se_paso = false;
    indice = size(cartas_C, 1) + 1;
    
    switch estrategia
        case 'probabilidad'
            % --- Estrategia de Probabilidades (Casino Inteligente) ---
            while true
                puntos_casa = calcular_puntos(P_C);
                
                % Si se pasó de 21 -> pierde
                if puntos_casa > 21
                    se_paso = true;
                    return;
                end
                
                % Calcular probabilidades matemáticas
                [Pg, Pp] = calcular_prob_sim(baraja, P_C);
                
                % Decidir si se planta basado en la matemática
                if debe_plantarse_sim(puntos_casa, Pp)
                    return;
                end
                
                % Si decide no plantarse, pide carta
                [carta, baraja] = sacar_carta_sim(baraja);
                cartas_C(indice, :) = carta;
                P_C(indice) = carta(2);
                indice = indice + 1;
            end
            
        case 'valor_objetivo'
            % --- Estrategia Clásica de Casino (Umbral 17) ---
            umbral = 17;
            
            while true
                puntos_casa = calcular_puntos(P_C);
                
                if puntos_casa > 21
                    se_paso = true;
                    return;
                end
                
                if puntos_casa >= umbral
                    return;
                end
                
                [carta, baraja] = sacar_carta_sim(baraja);
                cartas_C(indice, :) = carta;
                P_C(indice) = carta(2);
                indice = indice + 1;
            end
            
        otherwise
            % Estrategia por defecto
            [puntos_casa, se_paso] = turno_casa_auto(baraja, 'valor_objetivo', cartas_C, P_C);
    end
end

% ==========================================
% FUNCIONES DE PROBABILIDAD (ADAPTADAS A BLACKJACK)
% ==========================================

function [Pg, Pp] = calcular_prob_sim(baraja, P_C)
    % Calculamos la probabilidad exacta de pasarse (Pp) evaluando la baraja restante
    puntos_actuales = calcular_puntos(P_C);
    num_desconocidas = size(baraja, 1);
    bustos = 0;
    
    for i = 1:num_desconocidas
        % Simulamos qué pasa si sacamos esta carta (maneja dinámicamente el As)
        puntos_simulados = calcular_puntos([P_C, baraja(i, 2)]);
        if puntos_simulados > 21
            bustos = bustos + 1;
        end
    end
    
    % Probabilidad de pasarse si pide otra carta
    Pp = bustos / num_desconocidas; 
    
    % Probabilidad heurística de tener una mano fuerte (Pg)
    Pg = puntos_actuales / 21; 
end

function decision = debe_plantarse_sim(puntos_casa, Pp)
    % El casino inteligente se planta si ya alcanzó el umbral clásico de 17,
    % o si el riesgo de pasarse (Pp) supera el 60% aunque tenga menos de 17.
    decision = (puntos_casa >= 17) || (Pp >= 0.60);
end




% TURNO DE LA CASA ANTERIOR
% function [puntos_casa, se_paso] = turno_casa_auto(baraja_original, baraja, cartas_J, P_J, estrategia)
%     se_paso = false;
% 
%     % Puntos visibles del jugador (la casa no ve la ultima carta)
%     if length(P_J) > 1
%         puntos_visibles_J = sum(P_J(1:end-1));
%     else
%         puntos_visibles_J = 0;  
%     end
% 
%     cartas_C = [];
%     P_C = [];
%     indice = 1;
% 
%     switch estrategia
%         case 'probabilidad'
%             while true
%                 [carta, baraja] = sacar_carta_sim(baraja);
%                 cartas_C(indice, :) = carta;
%                 P_C(indice) = carta(2);
%                 puntos_casa = sum(P_C);
%                 indice = indice + 1;
% 
%                 if puntos_casa > 7.5
%                     se_paso = true;
%                     return;
%                 end
% 
%                 [Pg, Pp] = calcular_prob_sim(baraja_original, cartas_J, cartas_C, puntos_visibles_J, puntos_casa);
% 
%                 if debe_plantarse_sim(Pg, Pp)
%                     return;
%                 end
%             end
% 
%         case 'valor_objetivo'
%             umbral = 5.5;
% 
%             while true
%                 [carta, baraja] = sacar_carta_sim(baraja);
%                 cartas_C(indice, :) = carta;
%                 P_C(indice) = carta(2);
%                 puntos_casa = sum(P_C);
%                 indice = indice + 1;
% 
%                 if puntos_casa > 7.5
%                     se_paso = true;
%                     return;
%                 end
% 
%                 % Función f1(mp) para la casa
%                 if puntos_casa > umbral
%                     return;
%                 end
%             end
% 
%         case 'valor_objetivo_aleatorio'
%             umbrales_posibles = [1:0.5:7]; % Excluye 5.5
%             umbral = umbrales_posibles(randi(length(umbrales_posibles)));
% 
%             while true
%                 [carta, baraja] = sacar_carta_sim(baraja);
%                 cartas_C(indice, :) = carta;
%                 P_C(indice) = carta(2);
%                 puntos_casa = sum(P_C);
%                 indice = indice + 1;
% 
%                 if puntos_casa > 7.5
%                     se_paso = true;
%                     return;
%                 end
% 
%                 if puntos_casa > umbral
%                     return;
%                 end
%             end
% 
%         otherwise
%             [puntos_casa, se_paso] = turno_casa_auto(baraja_original, baraja, cartas_J, P_J, 'valor_objetivo');
%     end
% end


%{
% PROBABILIDADES

function [Pg, Pp] = calcular_prob_sim(baraja_original, cartas_J, cartas_C, puntos_visibles_J, puntos_casa)
    % Quitar cartas conocidas (visibles del jugador + todas de la casa)
    cartas_conocidas = [cartas_J(1:end-1, :); cartas_C];
    baraja_nueva = baraja_original;
    for i = 1:size(cartas_conocidas, 1)
        idx = find(baraja_nueva(:,1) == cartas_conocidas(i,1) & baraja_nueva(:,3) == cartas_conocidas(i,3), 1);
        baraja_nueva(idx, :) = [];
    end

    num_desconocidas = size(baraja_nueva, 1);

    % Pg: Prob de ganar plantandose
    % P(A) = prob de que la carta oculta no pase al jugador
    Pg = 0;
    valores_unicos = unique(baraja_nueva(:, 2));
    matriz_eventos = zeros(length(valores_unicos), 2);
    matriz_eventos(:, 1) = valores_unicos;

    for i = 1:length(valores_unicos)
        if valores_unicos(i) + puntos_visibles_J <= 7.5
            matriz_eventos(i, 2) = sum(baraja_nueva(:, 2) == valores_unicos(i));
        end
    end

    vector_prob = matriz_eventos(:, 2) / num_desconocidas;
    PA = sum(vector_prob);  % P(jugador no se paso)

    % P(B|A) = prob de que la casa gane DADO que el jugador no se paso
    if PA > 0
        PBA = vector_prob / PA;
        for i = 1:size(matriz_eventos, 1)
            if matriz_eventos(i, 2) > 0
                if puntos_casa >= puntos_visibles_J + matriz_eventos(i, 1)
                    Pg = Pg + PBA(i);
                end
            end
        end
    end

    % Pp: Prob de pasarse si la casa pide otra carta
    se_pasan = (baraja_nueva(:, 2) + puntos_casa) > 7.5;
    Pp = sum(se_pasan) / num_desconocidas;
end


% DECISION DE PLANTARSE
function decision = debe_plantarse_sim(Pg, Pp)
    decision = (Pg >= 0.7) || (Pg >= 0.1 && Pg < 0.7 && Pp >= 0.55);
end
%}