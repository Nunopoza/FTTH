% === simular_fibra_discontinua.m ===
clear; clc;

% === Coordenadas de las ciudades (ajusta si las tienes cargadas de antes)
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

% === Cargar la fibra
T = readtable('fibra_pais_vasco_completa.csv');

% === [AQUÍ METES TODO EL CÓDIGO de la simulación que te pasé arriba]
% === Número de simulaciones
N = 50;

% === Coordenadas de las ciudades (resumido aquí para ejemplo)
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

% === Cargar la red de fibra para referencia
T = readtable('fibra_pais_vasco_completa.csv');

ell = referenceEllipsoid('wgs84');
radio_km = 1;
radio_deg = radio_km / 111;

km_totales = zeros(N,1);

for sim = 1:N
    suma_km = 0;
    
    for i = 1:size(ciudades,1)
        lat_c = ciudades{i,2};
        lon_c = ciudades{i,3};

        % Buscar punto más cercano de la fibra
        dist = sqrt((T.Lat - lat_c).^2 + (T.Lon - lon_c).^2);
        [min_dist, idx_min] = min(dist);

        if min_dist > radio_deg
            lat_f = T.Lat(idx_min);
            lon_f = T.Lon(idx_min);

            % === Generar ruta curvada con puntos intermedios progresivos
            n_mid = 5;
            path_lat = zeros(n_mid+2, 1);
            path_lon = zeros(n_mid+2, 1);
            path_lat(1) = lat_c; path_lon(1) = lon_c;
            path_lat(end) = lat_f; path_lon(end) = lon_f;

            for k = 1:n_mid
                alpha = k / (n_mid + 1);
                base_lat = (1 - alpha)*lat_c + alpha*lat_f;
                base_lon = (1 - alpha)*lon_c + alpha*lon_f;
                path_lat(k+1) = base_lat + 0.003 * randn;
                path_lon(k+1) = base_lon + 0.003 * randn;
            end

            % === Suavizar ruta
            t = 1:length(path_lat);
            tt = linspace(1, length(path_lat), 100);
            lat_smooth = spline(t, path_lat, tt);
            lon_smooth = spline(t, path_lon, tt);

            % === Calcular longitud de la curva
            dist_km = 0;
            for j = 2:length(lat_smooth)
                d = distance(lat_smooth(j-1), lon_smooth(j-1), ...
                             lat_smooth(j),   lon_smooth(j), ...
                             ell, 'degrees');
                dist_km = dist_km + d / 1000;
            end

            suma_km = suma_km + dist_km;
        end
    end
    
    km_totales(sim) = suma_km;
end

% === Resultados
media_km = mean(km_totales);
std_km = std(km_totales);

fprintf(' Promedio estimado de fibra discontinua: %.2f km ± %.2f\n', media_km, std_km);
