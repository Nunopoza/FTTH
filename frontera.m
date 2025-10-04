%% === Script: frontera_punto_a_punto_viva.m ===
close all; clear; clc;

%% === 1. DEFINIR TRANSFORMACIÓN MANUAL (como con fibra)

% Puntos en la imagen (x, y) que marcaste sobre la imagen original
px = [110, 205, 398, 676];
py = [68,  225, 455,  58];

% Coordenadas reales de esos puntos (lat, lon)
lat_ref = [43.2669, 42.8982, 42.6811, 43.3133];
lon_ref = [-3.2646, -3.1218, -2.5439, -1.7493];

% Crear transformación afín
P = [px(:), py(:), ones(numel(px),1)];
lat_coeff = P \ lat_ref(:);
lon_coeff = P \ lon_ref(:);
pix2geo = @(x, y) deal( ...
    lat_coeff(1)*x + lat_coeff(2)*y + lat_coeff(3), ...
    lon_coeff(1)*x + lon_coeff(2)*y + lon_coeff(3));

%% === 2. ABRIR IMAGEN Y MAPA
img = imread('recorte_fibra_pv.jpg');
f1 = figure(1); clf;
imshow(img);
title('🖱️ Clica para trazar la frontera. ENTER para cerrar.');

% Mapa real
f2 = figure(2); clf;
gx = geoaxes;
geobasemap(gx, 'topographic'); hold(gx, 'on');
title(gx, 'Frontera en vivo (geo)');

%% === 3. CAPTURAR PUNTOS Y MOSTRAR EN VIVO

lat_pv = [];
lon_pv = [];

while true
    figure(f1);
    [x, y, btn] = ginput(1);

    % Salir si ENTER o fuera de imagen
    if isempty(x) || any(btn == 13)  % ENTER
        break;
    end

    % Convertir a geo
    [lat, lon] = pix2geo(x, y);
    lat_pv(end+1) = lat;
    lon_pv(end+1) = lon;

    % Dibujar en figura 2
    figure(f2);
    geoplot(gx, lat_pv, lon_pv, '-k', 'LineWidth', 2.5);
    drawnow;
end

%% === 4. GUARDAR A CSV

T = table((1:numel(lat_pv))', lat_pv(:), lon_pv(:), ...
    'VariableNames', {'PuntoID','Lat','Lon'});
writetable(T, 'frontera_pais_vasco_manual.csv');
disp('✅ Frontera guardada como frontera_pais_vasco_manual.csv');
