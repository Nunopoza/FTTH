trafico_csv = readtable('trafico_ciudades.csv');

% Cargar tabla original (con tipo, lat, lon, etc.)
% Puedes mantener esta si quieres preservar más info:
% === 1. Definir tabla original a mano (tú ya tenías esto) ===
datos = table( ...
    ["Bilbao"; "Vitoria-Gasteiz"; "Donostia/San Sebastián"; ...
     "Barakaldo"; "Basauri"; "Getxo"; "Leioa"; "Portugalete"; ...
     "Santurtzi"; "Sestao"; "Erandio"; "Galdakao"; "Durango"; ...
     "Eibar"; "Zarautz"; "Tolosa"; "Hernani"; "Errenteria"; ...
     "Irun"; "Hondarribia"; "Arrasate/Mondragón"], ...
    [43.2630; 42.8467; 43.3183; 43.2956; 43.2415; 43.3566; ...
     43.3198; 43.3200; 43.3281; 43.3106; 43.3125; 43.2308; ...
     43.1728; 43.1836; 43.2843; 43.1357; 43.2642; 43.3113; ...
     43.3375; 43.3689; 43.0650], ...
    [-2.9350; -2.6716; -1.9812; -2.9973; -2.8850; -3.0084; ...
     -2.9867; -3.0206; -3.0326; -2.9884; -2.9741; -2.8379; ...
     -2.6320; -2.4756; -2.1697; -2.0723; -1.9763; -1.8979; ...
     -1.7880; -1.7967; -2.4937], ...
    ["Hub"; "Hub"; "Hub"; "Metropolit."; "Metropolit."; "Metropolit."; ...
     "Metropolit."; "Metropolit."; "Metropolit."; "Metropolit."; ...
     "Metropolit."; "Periferia"; "Periferia"; "Periferia"; ...
     "Periferia"; "Periferia"; "Periferia"; "Periferia"; ...
     "Nodo Frontera"; "Nodo Frontera"; "Industrial"], ...
    'VariableNames', {'Ciudad','Lat','Lon','Tipo'});

% Leer CSV con tráfico
trafico_csv = readtable("trafico_ciudades.csv");

% Unir tablas por ciudad
datos = outerjoin(datos, trafico_csv, ...
    'LeftKeys', "Ciudad", ...
    'RightKeys', "Ciudad", ...
    'Type', 'left', ...
    'MergeKeys', true);

% Convertir a número por si vienen como string/cell
datos.TRAFICO_EN_HC_BPS = str2double(string(datos.TRAFICO_EN_HC_BPS));

% Crear Traf_Med (en Gbps)
datos.Traf_Med = datos.TRAFICO_EN_HC_BPS / 1e9;

% Rellenar vacíos con estimación aleatoria
idx_nan = isnan(datos.Traf_Med);
datos.Traf_Med(idx_nan) = 10 + 5 * rand(sum(idx_nan), 1);


% Estimar capacidad máxima como un 50% más del tráfico medio
datos.Traf_Max = datos.Traf_Med * 1.5;

% Calcular uso actual (entre 0 y 1)
datos.Uso = datos.Traf_Med ./ datos.Traf_Max;

% Coordenadas de las ciudades principales
ciudades = {'Bilbao', 'Vitoria-Gasteiz', 'Donostia/San Sebastián', ...
    'Barakaldo', 'Basauri', 'Getxo', 'Leioa', 'Portugalete', ...
    'Santurtzi', 'Sestao', 'Erandio', 'Galdakao', 'Durango', ...
    'Eibar', 'Zarautz', 'Tolosa', 'Hernani', 'Errenteria', ...
    'Irun', 'Hondarribia', 'Arrasate/Mondragón'};

latitudes = [43.2630, 42.8467, 43.3183, 43.2956, 43.2415, 43.3566, ...
    43.3198, 43.3200, 43.3281, 43.3106, 43.3125, 43.2308, ...
    43.1728, 43.1836, 43.2843, 43.1357, 43.2642, 43.3113, ...
    43.3375, 43.3689, 43.0650];

longitudes = [-2.9350, -2.6716, -1.9812, -2.9973, -2.8850, -3.0084, ...
    -2.9867, -3.0206, -3.0326, -2.9884, -2.9741, -2.8379, ...
    -2.6320, -2.4756, -2.1697, -2.0723, -1.9763, -1.8979, ...
    -1.7880, -1.7967, -2.4937];

figure;
geobasemap satellite;
hold on;

% Dentro del for actual, después de pintar ciudades
% Aquí empieza tu bucle principal
for i = 1:height(datos)

    % Pintar ciudades (ya lo tienes hecho)
    geoplot(datos.Lat(i), datos.Lon(i), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    text(datos.Lat(i), datos.Lon(i), datos.Ciudad{i}, 'Color', 'white', 'FontSize', 9, ...
        'HorizontalAlignment', 'left');

    % === Añade EXACTAMENTE AQUÍ este bloque ===
    if strcmp(datos.Ciudad{i}, 'Vitoria-Gasteiz')
        % Ruta realista por AP-68 (Vitoria - Logroño - Zaragoza)
        lat_ruta_zgz = [
            42.8467   % Vitoria-Gasteiz
            42.6865   % Miranda de Ebro
            42.5763   % Haro
            42.4627   % Logroño
            42.3051   % Calahorra
            42.0631   % Tudela
            41.6488   % Zaragoza
        ];

        lon_ruta_zgz = [
            -2.6716   % Vitoria
            -2.9469   % Miranda de Ebro
            -2.8470   % Haro
            -2.4440   % Logroño
            -1.9650   % Calahorra
            -1.6064   % Tudela
            -0.8891   % Zaragoza
        ];

        % Dibujar fibra troncal (base transparente)
        geoplot(lat_ruta_zgz, lon_ruta_zgz, '-', 'LineWidth', 8, 'Color', [0.4 0 1 0.2]);

        % Línea superior resaltada
        geoplot(lat_ruta_zgz, lon_ruta_zgz, '-', 'LineWidth', 3.5, 'Color', [0.9 0 1]);

        % Nodo final Zaragoza (Data Center)
        geoplot(lat_ruta_zgz(end), lon_ruta_zgz(end), 's', ...
            'MarkerSize', 10, ...
            'MarkerFaceColor', [1 0 1], ...
            'MarkerEdgeColor', 'w');
        text(lat_ruta_zgz(end), lon_ruta_zgz(end), 'Zaragoza (DC)', ...
            'Color', 'white', 'FontSize', 9, 'HorizontalAlignment', 'left');

        % Etiqueta sobre tramo
        lat_mid = mean(lat_ruta_zgz(3:5));
        lon_mid = mean(lon_ruta_zgz(3:5));
        text(lat_mid, lon_mid, 'Fibra troncal (AP-68)', ...
            'Color', 'magenta', 'FontSize', 8, 'FontWeight', 'bold');
    end
    
end % fin del bucle for



% Pintar nodos con color y tamaño según tipo o tráfico
for i = 1:height(datos)
    tipo = datos.Tipo{i};
    trafico = datos.Traf_Med(i);

    % Color según tipo
    switch tipo
        case 'Hub'
            color = [1 0 0];      % rojo
        case 'Metropolit.'
            color = [1 0.5 0.1];  % naranja
        case 'Periferia'
            color = [0.8 0.8 0.2]; % amarillo
        case 'Nodo Frontera'
            color = [0.2 0.6 1];  % azul claro
        case 'Industrial'
            olor = [0.2 1 0.2];  % verde brillante
        otherwise
            color = [0.5 0.5 0.5]; % gris
    end

    % Dibujo en el mapa
    geoplot(datos.Lat(i), datos.Lon(i), 'o', ...
        'MarkerSize', size_pt, ...
        'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', color);

    % Etiqueta
    text(datos.Lat(i), datos.Lon(i), ...
        sprintf('%s\n%.1f Gbps', datos.Ciudad{i}, trafico), ...
        'Color', 'white', 'FontSize', 8, 'HorizontalAlignment', 'left');
end


% Anillo principal
lat_anillo = [43.2630, 43.1432, 43.0493, 42.8540, 42.8467, ...
              42.8570, 43.0500, 43.1357, 43.3183, ...
              43.2843, 43.1836, 43.1728, 43.2630];
lon_anillo = [-2.9350, -2.9645, -2.9981, -2.8089, -2.6716, ...
              -2.4910, -2.1992, -2.0723, -1.9812, ...
              -2.1697, -2.4756, -2.6320, -2.9350];

fibra_main = @(lat, lon) [
    geoplot(lat, lon, '-', 'LineWidth', 3, 'Color', [0 1 0.2 0.2])
    geoplot(lat, lon, '-', 'LineWidth', 1, 'Color', [0 1 0])
    geoplot(lat, lon, '-', 'LineWidth', 0.35, 'Color', [0.8 1 0.8])
];

fibra_main(lat_anillo, lon_anillo);

% Conexiones realistas al anillo
conexiones = {
    'Barakaldo', 43.2630, -2.9350;
    'Basauri', 43.2630, -2.9350;
    'Getxo', 43.2630, -2.9350;
    'Leioa', 43.2630, -2.9350;
    'Portugalete', 43.2630, -2.9350;
    'Santurtzi', 43.2630, -2.9350;
    'Sestao', 43.2630, -2.9350;
    'Erandio', 43.2630, -2.9350;
    'Galdakao', 43.2630, -2.9350;
    'Durango', 43.1728, -2.6320;
    'Eibar', 43.1836, -2.4756;
    'Zarautz', 43.2843, -2.1697;
    'Tolosa', 43.1357, -2.0723;
    'Hernani', 43.2642, -1.9763;
    'Errenteria', 43.3113, -1.8979;
    'Irun', 43.3375, -1.7880;
    'Hondarribia', 43.3689, -1.7967;
    'Arrasate/Mondragón', 43.0493, -2.9981
};

fibra_rama = @(lat, lon) [
    geoplot(lat, lon, '-', 'LineWidth', 1, 'Color', [0 0.9 0.4 0.15])
    geoplot(lat, lon, '-', 'LineWidth', 0.3, 'Color', [0 1 0])
];

% Mismo código base que el tuyo, modificando solo la parte de las ramas
for i = 1:height(datos)
    ciudad = datos.Ciudad{i};

    % No conectar los hubs (ya están en el anillo)
    if ismember(ciudad, ["Bilbao", "Vitoria-Gasteiz", "Donostia/San Sebastián"])
        continue;
    end

    lat_ciu = datos.Lat(i);
    lon_ciu = datos.Lon(i);
    traf = datos.Traf_Med(i);

    % Encontrar punto más cercano del anillo
    distancias = hypot(lat_ciu - lat_anillo, lon_ciu - lon_anillo);
    [~, idx_min] = min(distancias);
    lat_obj = lat_anillo(idx_min);
    lon_obj = lon_anillo(idx_min);

    % Generar camino curvado (random walk suave)
    n_points = 6;
    lat_path = linspace(lat_ciu, lat_obj, n_points);
    lon_path = linspace(lon_ciu, lon_obj, n_points);
    deviation = 0.01;
    lat_path(2:end-1) = lat_path(2:end-1) + deviation * (rand(1, n_points-2) - 0.5);
    lon_path(2:end-1) = lon_path(2:end-1) + deviation * (rand(1, n_points-2) - 0.5);

    % Escalar grosor de línea (mínimo 1.2, máximo 6)
    grosor = rescale(traf, 1.2, 6);

    % Color por tráfico (verde → amarillo → rojo → morado si es muy bestia)
    if traf < 20
        color = [0 1 0];       % verde
    elseif traf < 40
        color = [1 1 0];       % amarillo
    elseif traf < 60
        color = [1 0.5 0];     % naranja
    elseif traf < 80
        color = [1 0 0];       % rojo
    else
        color = [0.6 0 1];     % morado (crítico)
    end


    % Dibujar la rama con dos capas (glow y centro)
    geoplot(lat_path, lon_path, '-', ...
        'LineWidth', grosor + 3, 'Color', [color 0.2]); % halo
    geoplot(lat_path, lon_path, '-', ...
        'LineWidth', grosor, 'Color', color);           % centro
end

title('Anillo de Fibra Óptica con Ramas Reales en el País Vasco');

% === RANKING TOP 5 POR TRÁFICO ===
[traf_ordenado, orden] = sort(datos.Traf_Med, 'descend');
top_n = 5;

fprintf('\n TOP %d CIUDADES CON MÁS TRÁFICO:\n', top_n);
fprintf('------------------------------------\n');
for i = 1:top_n
    idx = orden(i);
    fprintf('%d. %-25s  %.2f Gbps\n', i, datos.Ciudad{idx}, traf_ordenado(i));
end

% Filtrar ciudades con más del X% de uso
%altas = datos.Uso > 0.45;

% Ver cuáles son:
fprintf('------------------------------------\n');
%fprintf('Ciudades con X porciento de uso\n');
%disp(datos.Ciudad(altas))


%% Estadísticas de la red

% 1. Métricas generales
media_traf = mean(datos.Traf_Med);
mediana_traf = median(datos.Traf_Med);
std_traf = std(datos.Traf_Med);
cv_traf = std_traf / media_traf;  % coeficiente de variación

fprintf('\n Estadísticas del tráfico:\n');
fprintf('Media:   %.2f Gbps\n', media_traf);
fprintf('Mediana: %.2f Gbps\n', mediana_traf);
fprintf('Std:     %.2f Gbps\n', std_traf); 
fprintf('CV:      %.2f\n', cv_traf); %Coeficiente de variación

% 2. Z-score por ciudad
datos.Zscore = (datos.Traf_Med - media_traf) / std_traf;

% Marcar ciudades "anómalas" si z > 2 o < -2
datos.Anomalo = abs(datos.Zscore) > 2;

fprintf('\n Ciudades con tráfico anómalo:\n');
disp(datos.Ciudad(datos.Anomalo));

% 3. Clasificar por cuartiles de Traf_Med
Q1 = prctile(datos.Traf_Med, 25);
Q2 = prctile(datos.Traf_Med, 50);
Q3 = prctile(datos.Traf_Med, 75);

datos.Nivel_Carga = repmat("Baja", height(datos), 1);
datos.Nivel_Carga(datos.Traf_Med > Q1) = "Media";
datos.Nivel_Carga(datos.Traf_Med > Q2) = "Alta";
datos.Nivel_Carga(datos.Traf_Med > Q3) = "Crítica";


%% Grafo Dijkstra

% Suponiendo que ya tienes la tabla 'datos' cargada con Traf_Med
G = grafo_fibra(datos);

% Ver el grafo con pesos por tráfico
figure;
p = plot(G, 'Layout', 'force', ...
    'EdgeLabel', round(G.Edges.Weight,1), ...
    'NodeColor', [0.2 0.6 1], ...
    'EdgeColor', [0.7 0.7 0.7], ...
    'LineWidth', 1.5, ...
    'MarkerSize', 7);
title('Red de fibra con pesos por tráfico medio');

% === Calcular y pintar ruta óptima según menor carga ===
origen = "Bilbao";
destino = "Irun";

[camino, coste] = shortestpath(G, origen, destino);

fprintf('\n Ruta óptima (menos carga) de %s a %s:\n', origen, destino);
disp(camino);
fprintf(' Carga total en ruta: %.2f Gbps\n', coste);

