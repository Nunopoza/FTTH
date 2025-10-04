%% === CONFIGURAR LA TRANSFORMACIÓN ===
img = imread('recorte_fibra_pv.jpg');
f1 = figure(1); clf;
ax = axes(f1);
imshow(img, 'Parent', ax);
title('Haz clic en: 1) Bilbao, 2) Vitoria, 3) Donostia, 4) Irun');
[x, y] = ginput(4);

lat_ref = [43.2630, 42.8467, 43.3183, 43.3375];
lon_ref = [-2.9350, -2.6716, -1.9812, -1.7880];

P = [x, y, ones(4,1)];
lat_coeff = P \ lat_ref(:);
lon_coeff = P \ lon_ref(:);
pix2geo = @(x, y) deal( ...
    lat_coeff(1)*x + lat_coeff(2)*y + lat_coeff(3), ...
    lon_coeff(1)*x + lon_coeff(2)*y + lon_coeff(3));

%% === PREPARAR MAPA EN VENTANA 2
f2 = figure(2); clf;
gx = geoaxes(f2);
geobasemap(gx, 'satellite');
hold(gx, 'on');
title(gx, 'Fibra sobre mapa real');

%% === TRAZAR RUTAS UNA A UNA
todo_lat = [];
todo_lon = [];
todo_id = [];
rutaID = 1;

while true
    figure(1);
    imshow(img, 'Parent', ax);
    title(sprintf('Ruta %d: haz clic para trazar. ENTER para guardar. ESC para salir.', rutaID));
    
    [xr, yr, btn] = ginput;
    if isempty(xr) || any(btn == 27)  % ESC
        break;
    end

    [lat, lon] = pix2geo(xr, yr);

    todo_lat = [todo_lat; lat(:)];
    todo_lon = [todo_lon; lon(:)];
    todo_id = [todo_id; rutaID * ones(size(lat))];

    figure(2);
    geoplot(gx, lat, lon, '-', 'LineWidth', 2, ...
        'Color', [1 0.6 0.1], 'DisplayName', sprintf('Ruta %d', rutaID));
    legend(gx, 'show');

    rutaID = rutaID + 1;
end


%% === GUARDAR TODO
T = table(todo_id, todo_lat, todo_lon, ...
    'VariableNames', {'RutaID','Lat','Lon'});
writetable(T, 'fibra_pais_vasco_completa.csv');
disp('✅ Guardado como fibra_pais_vasco_completa.csv');
