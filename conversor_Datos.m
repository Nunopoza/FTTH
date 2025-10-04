S = shaperead('TERRITORIOS_5000_ETRS89.shp');

% Buscar el polígono del País Vasco (ej. código 16 o nombre)
for i = 1:length(S)
    if contains(S(i).NATCODE, '16') || contains(S(i).NAMEUNIT, 'Vasco')
        lat_pv = S(i).Y;
        lon_pv = S(i).X;
        break;
    end
end

% Dibujar contorno
geoplot(gx, lat_pv, lon_pv, '-', 'LineWidth', 2, 'Color', [0.2 0.6 1]);
