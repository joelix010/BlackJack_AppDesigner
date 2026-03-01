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

% ==========================================
% FUNCIONES AUXILIARES
% ==========================================

% CALCULAR PUNTOS
function puntos = calcular_puntos(valores_cartas)
    puntos = sum(valores_cartas);
    num_ases = sum(valores_cartas == 11);
    % Ajuste dinámico del As
    while puntos > 21 && num_ases > 0
        puntos = puntos - 10;
        num_ases = num_ases - 1;
    end
end

% BARAJA
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

% SACAR CARTA
function [carta, baraja] = sacar_carta_sim(baraja)
    carta = baraja(1, :);
    baraja(1, :) = [];
end

% >>> TURNO DEl JUGADOR <<<
function [cartas_J, P_J, baraja, se_paso] = turno_jugador_auto(baraja, estrategia, cartas_J, P_J, carta_visible_casa)
    
    % Se calcula el índice basado en las cartas que el jugador YA tiene (usualmente 2 al iniciar)
    indice = size(cartas_J, 1) + 1;
    se_paso = false;
    
    %Comienzo del Switch
    switch estrategia
        
        %-------- Implementacion: 1) Valor Objetivo
        case 'Valor Objetivo'
            % --- Valor Objetivo (Basado en Probabilidad de pasarse) ---
            % Se pide carta siempre y cuando el riesgo de pasarse sea menor al 50%
            
            while true
                puntos_J = calcular_puntos(P_J);
                
                % Si se pasó de 21 -> pierde
                if puntos_J > 21
                    se_paso = true;
                    return;
                end
                
                % Si tiene 21 exacto, se planta automáticamente para no arruinarlo
                if puntos_J == 21
                    return;
                end
                
                % --- Calcular probabilidad exacta de pasarse (Pp) ---
                bustos = 0;
                num_cartas_restantes = size(baraja, 1);
                
                for c = 1:num_cartas_restantes
                    % Simulamos qué pasaría con los puntos si sacamos esta carta específica
                    % (Usamos calcular_puntos para que maneje correctamente si la carta es un As)
                    puntos_simulados = calcular_puntos([P_J, baraja(c, 2)]);
                    if puntos_simulados > 21
                        bustos = bustos + 1;
                    end
                end
                
                Pp = bustos / num_cartas_restantes;
                
                % Si hay >= 50% de probabilidad de pasarse, se planta y termina el turno
                if Pp >= 0.5
                    return; 
                end
                
                % Si la probabilidad es segura (riesgo < 50%), pide otra carta
                [carta, baraja] = sacar_carta_sim(baraja);
                cartas_J(indice, :) = carta;
                P_J(indice) = carta(2);
                indice = indice + 1;
            end
        % --------- Fin de implementacion 1) --------------------------
        
        %-------- Implementacion: 2) Del repartidor
        case 'Del repartidor'
            % Estrategia del Repartidor (Dealer)
            % Regla estricta: Pedir si tiene 16 o menos. Plantarse con 17 o más.
            
            while true
                puntos_J = calcular_puntos(P_J);
                
                % Si se pasó de 21 -> pierde
                if puntos_J > 21
                    se_paso = true;
                    return;
                end
                
                % Si tiene menos de 17, está obligado a pedir carta
                if puntos_J < 17
                    [carta, baraja] = sacar_carta_sim(baraja);
                    cartas_J(indice, :) = carta;
                    P_J(indice) = carta(2);
                    indice = indice + 1;
                else
                    % Si tiene 17 o más, está obligado a plantarse y termina su turno
                    return;
                end
            end
        % --------- Fin de implementacion 2) --------------------------
        
        %-------- Implementacion: 3) Del puntaje Optimo (JJ)
        case 'optimo'
            % Estrategia del Puntaje Óptimo (Estrategia Básica simplificada)
            % carta_visible_casa es un array [numero, valor, palo], el valor está en la pos 2
            valor_casa = carta_visible_casa(2);
            
            while true
                puntos_J = calcular_puntos(P_J);
                
                % Verificar si ya se pasó
                if puntos_J > 21
                    se_paso = true;
                    return;
                end
                
                % Determinar si la mano es "suave" (tiene un As valiendo 11 sin pasarse)
                ases_totales = sum(P_J == 11);
                ases_reducidos = (sum(P_J) - puntos_J) / 10; % Cuántos Ases se convirtieron en 1
                es_suave = (ases_totales > ases_reducidos);
                
                % Bandera para decidir si pedimos o nos plantamos
                pedir_carta = false;
                
                % LÓGICA DE DECISIÓN (Estrategia Básica de Blackjack)
                if es_suave
                    % Reglas para manos suaves
                    if puntos_J <= 17
                        pedir_carta = true;
                    elseif puntos_J == 18
                        % Si tenemos 18 suave, pedimos solo si la casa tiene una carta fuerte (9, 10, As)
                        if valor_casa >= 9 
                            pedir_carta = true;
                        end
                    end
                    % Si es 19 o 20 suave, nos plantamos (pedir_carta se queda false)
                else
                    % Reglas para manos duras
                    if puntos_J <= 11
                        % Siempre pedir si no hay riesgo de pasarse
                        pedir_carta = true;
                    elseif puntos_J == 12
                        % Con 12, plantarse si la casa tiene una carta débil (4, 5, 6), si no, pedir
                        if valor_casa < 4 || valor_casa > 6
                            pedir_carta = true;
                        end
                    elseif puntos_J >= 13 && puntos_J <= 16
                        % Con 13-16, plantarse si la casa tiene carta débil (2-6), pedir si es fuerte (7-11)
                        if valor_casa >= 7
                            pedir_carta = true;
                        end
                    end
                    % Si es 17 duro o más, nos plantamos siempre
                end
                
                % Ejecutar la decisión
                if pedir_carta
                    [carta, baraja] = sacar_carta_sim(baraja);
                    cartas_J(indice, :) = carta;
                    P_J(indice) = carta(2);
                    indice = indice + 1;
                else
                    % Nos plantamos y terminamos el turno
                    return;
                end
            end
        % --------- Fin de implementacion 3) --------------------------
        
        %-------- Implementacion: 4) Doblar apuesta (JJ)
        case 'doblar_apuesta'
            % Estrategia: Doblar apuesta
            % Regla: Si las 2 cartas iniciales suman 9, 10 u 11, se dobla.
            % Al doblar, se pide EXACTAMENTE UNA CARTA y termina el turno.
            
            puntos_J = calcular_puntos(P_J);
            
            % Verificamos si tiene exactamente 2 cartas y suma 9, 10 u 11
            if length(P_J) == 2 && (puntos_J >= 9 && puntos_J <= 11)
                
                % Pide EXACTAMENTE UNA carta
                [carta, baraja] = sacar_carta_sim(baraja);
                cartas_J(indice, :) = carta;
                P_J(indice) = carta(2);
                
                puntos_J = calcular_puntos(P_J);
                
                % Verificamos si se pasó (poco probable sacando 1 carta con 9-11, pero por seguridad)
                if puntos_J > 21
                    se_paso = true;
                end
                
                % Termina el turno obligatoriamente (forzado a plantarse)
                return;
                
            else
                % Si la mano no es apta para doblar (ej. tiene 15), jugamos normal.
                % Llamamos recursivamente a la función usando la estrategia 'optimo'
                [cartas_J, P_J, baraja, se_paso] = turno_jugador_auto(baraja, 'optimo', cartas_J, P_J, carta_visible_casa);
                return;
            end
        % --------- Fin de implementacion 4) --------------------------
        
        %-------- Implementacion: 5) Dividir Juego (JJ)
        case 'dividir_juego'
            % Estrategia: Dividir Juego (Split)
            % Regla: Si las 2 cartas iniciales tienen el mismo valor, se separan.
            
            % Verificamos si tiene exactamente 2 cartas y si tienen el mismo valor numérico
            if length(P_J) == 2 && P_J(1) == P_J(2)
                
                % Separamos las cartas iniciales
                mano1_cartas = cartas_J(1, :);
                mano1_P = P_J(1);
                
                mano2_cartas = cartas_J(2, :);
                mano2_P = P_J(2);
                
                % --- JUGAR LA MANO 1 ---
                % Repartimos la segunda carta obligatoria para la Mano 1
                [carta_nueva1, baraja] = sacar_carta_sim(baraja);
                mano1_cartas = [mano1_cartas; carta_nueva1];
                mano1_P = [mano1_P, carta_nueva1(2)];
                
                % Jugamos la mano 1 completa usando la estrategia básica ('optimo')
                [mano1_cartas, mano1_P, baraja, se_paso1] = turno_jugador_auto(baraja, 'optimo', mano1_cartas, mano1_P, carta_visible_casa);
                
                % --- JUGAR LA MANO 2 ---
                % Repartimos la segunda carta obligatoria para la Mano 2
                [carta_nueva2, baraja] = sacar_carta_sim(baraja);
                mano2_cartas = [mano2_cartas; carta_nueva2];
                mano2_P = [mano2_P, carta_nueva2(2)];
                
                % Jugamos la mano 2 completa usando la estrategia básica ('optimo')
                [mano2_cartas, mano2_P, baraja, se_paso2] = turno_jugador_auto(baraja, 'optimo', mano2_cartas, mano2_P, carta_visible_casa);
                
                % --- GUARDAR RESULTADOS DE AMBAS MANOS ---
                % Como ahora hay DOS manos, devolvemos 'Cell Arrays' (arreglos de celdas)
                % para encapsular la información y no mezclarla.
                cartas_J = {mano1_cartas, mano2_cartas};
                P_J = {mano1_P, mano2_P};
                se_paso = [se_paso1, se_paso2]; % Array lógico con estado de ambas manos
                
                return;
                
            else
                % Si no son pares (ej. 10 y 6), no se puede dividir.
                % Jugamos de forma normal usando la estrategia básica de respaldo.
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