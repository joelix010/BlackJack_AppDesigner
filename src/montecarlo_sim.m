function resultados = montecarlo_sim(num_iteraciones, estrategia_jugador, estrategia_casa)

    victorias_jugador = 0;
    victorias_casa    = 0;
    empates           = 0;

    for iter = 1:num_iteraciones
        % crear y barajear mazo
        baraja_original = crear_baraja_sim();
        baraja = baraja_original(randperm(52), :);

        % repartir cartas
        [carta1_J, baraja] = sacar_carta_sim(baraja);  % 1ra carta jugador (boca arriba)
        [carta1_C, baraja] = sacar_carta_sim(baraja);  % 1ra carta casa (boca arriba)
        [carta2_J, baraja] = sacar_carta_sim(baraja);  % 2da carta jugador (boca arriba)
        [carta2_C, baraja] = sacar_carta_sim(baraja);  % 2da carta casa (boca abajo)

        % mano inicial del jugador (2 cartas)
        cartas_J = [carta1_J; carta2_J];
        P_J = [carta1_J(2), carta2_J(2)];

        % mano inicial de la casa (2 cartas)
        cartas_C = [carta1_C; carta2_C];
        P_C = [carta1_C(2), carta2_C(2)];

        puntos_J = calcular_puntos(P_J);
        puntos_C = calcular_puntos(P_C);

        blackjack_J = (puntos_J == 21);
        blackjack_C = (puntos_C == 21);

        % verificar blackjack (21 con 2 cartas)
        if blackjack_J && blackjack_C
            empates = empates + 1;
            continue;
        elseif blackjack_J
            victorias_jugador = victorias_jugador + 1;
            continue;
        elseif blackjack_C
            victorias_casa = victorias_casa + 1;
            continue;
        end

        % turno del jugador (ya tiene 2 cartas)
        [cartas_J, P_J, baraja, jugador_se_paso] = turno_jugador_auto(baraja, estrategia_jugador, cartas_J, P_J, carta1_C);

        if jugador_se_paso
            victorias_casa = victorias_casa + 1;
            continue;
        end

        % turno de la casa
        [puntos_casa, casa_se_paso] = turno_casa_auto(baraja, estrategia_casa, cartas_C, P_C, P_J);
        if casa_se_paso
            victorias_jugador = victorias_jugador + 1;
            continue;
        end
        % comparar puntos finales
        puntos_J = calcular_puntos(P_J);
        if puntos_casa > puntos_J
            victorias_casa = victorias_casa + 1;
        elseif puntos_casa == puntos_J
            empates = empates + 1;
        else
            victorias_jugador = victorias_jugador + 1;
        end
    end

    % armar struct de resultados
    resultados.victorias_jugador  = victorias_jugador;
    resultados.victorias_casa     = victorias_casa;
    resultados.empates            = empates;
    resultados.porcentaje_jugador = (victorias_jugador / num_iteraciones) * 100;
    resultados.porcentaje_casa    = (victorias_casa / num_iteraciones) * 100;
end


% baraja inglesa contiene 52 cartas
% Columna 1: numero (1=As, 2-10, 11=J, 12=Q, 13=K)
% Columna 2: valor HARD (As=1, figuras=10)
% Columna 3: valor SOFT (As=11, figuras=10)
% Columna 4: palo (1=Corazones, 2=Diamantes, 3=Treboles, 4=Picas)
function baraja = crear_baraja_sim()
    baraja = zeros(52, 4);
    numeros     = [1,  2:10, 11, 12, 13];
    valores_hard = [1,  2:10, 10, 10, 10];   % As = 1
    valores_soft = [11, 2:10, 10, 10, 10];   % As = 11
    for palo = 1:4
        rango = (palo-1)*13 + 1 : palo*13;
        baraja(rango, 1) = numeros;
        baraja(rango, 2) = valores_hard;
        baraja(rango, 3) = valores_soft;
        baraja(rango, 4) = palo;
    end
end




% sacar carta
function [carta, baraja] = sacar_carta_sim(baraja)
    carta = baraja(1, :);
    baraja(1, :) = [];
end


% turno del jugador
% Estrategias: valor, repartidor, optimo, doblar, dividir
function [cartas_J, P_J, baraja, se_paso] = turno_jugador_auto(baraja, estrategia, cartas_J, P_J, carta_visible_casa)
    se_paso = false;
    puntos_J = calcular_puntos(P_J);
    indice = size(cartas_J, 1) + 1;

    switch estrategia
        case 'valor'
            % Estrategia del Valor Objetivo
            % TODO: Implementar

        case 'repartidor'
            % Estrategia del Repartidor
            % TODO: Implementar

        case 'optimo'
            % Estrategia del Puntuaje Optimo
            % TODO: Implementar

        case 'doblar'
            % Estrategia Doblar Apuesta
            % TODO: Implementar

        case 'dividir'
            % Estrategia Dividir Juego
            % TODO: Implementar

        otherwise
            % Default: usar estrategia valor objetivo
            [cartas_J, P_J, baraja, se_paso] = turno_jugador_auto(baraja, 'valor', cartas_J, P_J, carta_visible_casa);
    end
end

% turno de la casa
% Estrategias: probabilistica, valor
function [puntos_casa, se_paso] = turno_casa_auto(baraja, estrategia, cartas_C, P_C, P_J)
    se_paso = false;
    puntos_casa = calcular_puntos(P_C);
    indice = size(cartas_C, 1) + 1;

    switch estrategia
        case 'probabilistica'
            % Estrategia de las Probabilidades
            % TODO: Implementar

        case 'valor'
            % Estrategia del Valor Objetivo
            % TODO: Implementar

        otherwise
            % Default: usar estrategia valor objetivo
            [puntos_casa, se_paso] = turno_casa_auto(baraja, 'valor', cartas_C, P_C, P_J);
    end
end