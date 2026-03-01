function total = calcular_puntaje(cartas_val)
    % Sumar el valor de todas las cartas
    total = sum(cartas_val);
    
    % Contar cuántos Ases (valor 11) hay en la mano
    num_ases = sum(cartas_val == 11);
    
    % Si nos pasamos de 21 y tenemos Ases, convertir los Ases de 11 a 1
    while total > 21 && num_ases > 0
        total = total - 10; % Restar 10 es equivalente a cambiar un 11 por un 1
        num_ases = num_ases - 1;
    end
end
