% Permite crear un archivo .mat con los valores de los nombres de los
% archivos de las imagenes de la baraja (Baraja_fig) y los valores
% correspondientes a su figura (Baraja_val)

function crear_variables_baraja()

    % 52 cartas: 4 palos * 13 cartas
    % Rutas en la carpeta 'Mazo_BlackJack'
    
    palos = {'Corazones', 'Diamantes', 'Picas', 'Treboles'};
    Baraja_fig = cell(1, 52);
    Baraja_val = zeros(1, 52);
    
    idx = 1;
    for p = 1:length(palos)
        palo = palos{p};
        for v = 1:13
            % Formar la ruta: 'Mazo_BlackJack/Corazones/1_de_Corazones.png'
            nombre_archivo = sprintf('Mazo_BlackJack/%s/%d_de_%s.png', palo, v, palo);
            Baraja_fig{idx} = nombre_archivo;
            
            % Asignar valor de la carta
            if v == 1
                Baraja_val(idx) = 11; % El As inicialmente vale 11
            elseif v >= 10
                Baraja_val(idx) = 10; % J (11), Q (12), K (13) y el 10 valen 10
            else
                Baraja_val(idx) = v;  % Las demás valen su número
            end
            
            idx = idx + 1;
        end
    end

    save("Baraja.mat", 'Baraja_fig', 'Baraja_val');
end