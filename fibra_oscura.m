%% === LIMPIAR ENTORNO Y FIGURAS ===
close all; clear; clc;

%% === CARGAR RUTAS DE FIBRA ===
T = readtable('fibra_pais_vasco_completa.csv');

%% === CREAR MAPA SATÉLITE LIMPIO ===
figure;
gx = geoaxes;
geobasemap(gx, 'topographic');
hold(gx, 'on');
title(gx, 'Red de Fibra y Ciudades del País Vasco');
%% === PINTAR FIBRA (morado brillante)
ids = unique(T.RutaID);
for i = 1:length(ids)
    idx = T.RutaID == ids(i);

    % Fibra en morado potente
    geoplot(gx, T.Lat(idx), T.Lon(idx), '-', ...
        'LineWidth', 1.5, ...
        'Color', [0.8 0.3 1]);
end

%% === CIUDADES (nombre, lat, lon)
ciudades = {
    'Vitoria-Gasteiz', 42.8467, -2.6716;
    'Eibar',            43.1836, -2.4756;
    'Hernani',          43.2642, -1.9763;
    'Irun',             43.3375, -1.7880;
    'Arrasate/Mondragón',43.0650, -2.4937;
    'Errenteria',       43.3113, -1.8979;
    'Donostia/San Sebastián',43.3183, -1.9812;
    'Tolosa',           43.1357, -2.0723;
    'Zarautz',          43.2843, -2.1697;
    'Barakaldo',        43.2956, -2.9973;
    'Basauri',          43.2415, -2.8850;
    'Bilbao',           43.2630, -2.9350;
    'Durango',          43.1728, -2.6320;
    'Galdakao',         43.2308, -2.8379;
    'Getxo',            43.3566, -3.0084;
    'Leioa',            43.3198, -2.9867;
    'Portugalete',      43.3200, -3.0206;
    'Santurtzi',        43.3281, -3.0326;
    'Sestao',           43.3106, -2.9884;
    'Erandio',          43.3125, -2.9741;
    'Hondarribia',      43.3689, -1.7967;
};

%% === MOSTRAR CIUDADES EN EL MAPA
for i = 1:size(ciudades,1)
    lat = ciudades{i,2};
    lon = ciudades{i,3};

    geoplot(gx, lat, lon, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');
    text(lat, lon, ciudades{i,1}, ...
        'FontSize', 9, 'Color', 'black', ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'top');
end

%% === CONECTAR CIUDADES SIN FIBRA CERCANA (< 1 KM)
radio_km = 1;
radio_deg = radio_km / 111;  % 1 grado ≈ 111 km

for i = 1:size(ciudades,1)
    lat_c = ciudades{i,2};
    lon_c = ciudades{i,3};

    % Distancias a todos los puntos de fibra
    dist = sqrt((T.Lat - lat_c).^2 + (T.Lon - lon_c).^2);
    [min_dist, idx_min] = min(dist);

    if min_dist > radio_deg
        lat_f = T.Lat(idx_min);
        lon_f = T.Lon(idx_min);
        
        % === Número de puntos intermedios
    n_mid = 5;
    
    % === Generar puntos intermedios progresivos (ciudad → fibra)
    path_lat = zeros(n_mid+2, 1);
    path_lon = zeros(n_mid+2, 1);
    
    path_lat(1) = lat_c;
    path_lon(1) = lon_c;
    
    path_lat(end) = lat_f;
    path_lon(end) = lon_f;
    
    for k = 1:n_mid
        alpha = k / (n_mid + 1);  % avanza de 0 → 1
        % Interpolación progresiva
        base_lat = (1 - alpha)*lat_c + alpha*lat_f;
        base_lon = (1 - alpha)*lon_c + alpha*lon_f;
        
        % Desviación lateral suave
        offset_lat = 0.003 * randn;  % puedes ajustar este valor
        offset_lon = 0.003 * randn;
    
        path_lat(k+1) = base_lat + offset_lat;
        path_lon(k+1) = base_lon + offset_lon;
    end
    
    % === Suavizar con spline
    t = 1:length(path_lat);
    tt = linspace(1, length(path_lat), 100);
    lat_smooth = spline(t, path_lat, tt);
    lon_smooth = spline(t, path_lon, tt);
    
    % === Dibujar la línea discontinua
    geoplot(gx, lat_smooth, lon_smooth, ':', ...
        'LineWidth', 2, ...
        'Color', [0.75 0.1 1]);  % morado suave

    % === Calcular distancia real sobre la curva
    ell = referenceEllipsoid('wgs84');
    dist_km = 0;
    
    for j = 2:length(lat_smooth)
        d = distance(lat_smooth(j-1), lon_smooth(j-1), ...
                     lat_smooth(j),   lon_smooth(j), ...
                     ell, 'degrees');     % devuelve en metros
        dist_km = dist_km + d / 1000;     % metros → km
    end
    
    % === Mostrar por terminal
    fprintf(' %s → Fibra: %.2f km\n', ciudades{i,1}, dist_km);
    
    % === Añadir etiqueta en el mapa
    mid_idx = round(length(lat_smooth)/2);
    lat_mid = lat_smooth(mid_idx);
    lon_mid = lon_smooth(mid_idx);
    
    text(lat_mid, lon_mid, sprintf('%.1f km', dist_km), ...
        'Color', [0.5 0 1], ...
        'FontSize', 9, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'BackgroundColor', 'w', ...
        'Margin', 1);

    end
end

% === Cargar rutas digitalizadas
T = readtable('fibra_pais_vasco_completa.csv');

% === Inicializar variables
total_km = 0;
ell = referenceEllipsoid('wgs84');

% === Recorrer todas las rutas
ids = unique(T.RutaID);
for i = 1:length(ids)
    idx = T.RutaID == ids(i);
    lat = T.Lat(idx);
    lon = T.Lon(idx);
    
    % Sumar distancias entre pares de puntos consecutivos
    for j = 2:length(lat)
        d = distance(lat(j-1), lon(j-1), lat(j), lon(j), ell, 'degrees');
        total_km = total_km + d / 1000;  % metros → km
    end
end

% === Mostrar el resultado
fprintf(' Total de fibra desplegada en el País Vasco: %.2f km\n', total_km);
