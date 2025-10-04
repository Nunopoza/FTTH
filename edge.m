function pais_vasco_hibrido
    close all; clc;

    % Ciudades >20k habitantes en País Vasco
    ciudades = {
        'Vitoria-Gasteiz','Araba',42.8467,-2.6716,false,true;
        'Bilbao','Bizkaia',43.2630,-2.9350,false,true;
        'Barakaldo','Bizkaia',43.2956,-2.9973,true,false;
        'Basauri','Bizkaia',43.2415,-2.8850,true,false;
        'Durango','Bizkaia',43.1728,-2.6320,true,false;
        'Galdakao','Bizkaia',43.2308,-2.8379,true,false;
        'Getxo','Bizkaia',43.3566,-3.0084,true,false;
        'Leioa','Bizkaia',43.3198,-2.9867,true,false;
        'Portugalete','Bizkaia',43.3200,-3.0206,true,false;
        'Santurtzi','Bizkaia',43.3281,-3.0326,true,false;
        'Sestao','Bizkaia',43.3106,-2.9884,true,false;
        'Erandio','Bizkaia',43.3125,-2.9741,true,false;
        'Donostia','Gipuzkoa',43.3183,-1.9812,false,true;
        'Eibar','Gipuzkoa',43.1836,-2.4756,true,false;
        'Irun','Gipuzkoa',43.3375,-1.7880,true,false;
        'Arrasate','Gipuzkoa',43.0650,-2.4937,true,false;
        'Errenteria','Gipuzkoa',43.3113,-1.8979,true,false;
        'Zarautz','Gipuzkoa',43.2843,-2.1697,true,false;
    };

    T = cell2table(ciudades, 'VariableNames', {'Nombre','Provincia','Lat','Lon','isFOADM','isROADM'});

    for i = 1:height(T)
        T.Lat(i) = ciudades{i,3};
        T.Lon(i) = ciudades{i,4};
        T.isFOADM(i) = logical(ciudades{i,5});
        T.isROADM(i) = logical(ciudades{i,6});
    end

    fig = figure('Position', [100, 100, 1400, 900], 'Color', 'w');
    gx = geoaxes('Parent', fig);

    drawnow; pause(1); refreshdata(gx);

    try
        geobasemap(gx, 'topographic');
    catch
        geobasemap(gx, 'grayland');
    end


    hold(gx, 'on');
    title(gx, 'AGGREGATION LAYER - Euskonect Network', 'FontSize', 20, 'FontWeight', 'bold');
    subtitle(gx, 'Backbone ROADM Ring & Provincial FOADM Nodes', 'FontSize', 16);
    geolimits(gx, [42.75 43.45], [-3.15 -1.65]);

    % Backbone ROADM
    ruta_vitoria_bilbao = [
        42.8467, -2.6716;
        42.9100, -2.7500;
        43.0532, -2.8736;
        43.1583, -2.9123;
        43.2292, -2.9267;
        43.2630, -2.9350
    ];

    ruta_bilbao_donostia = [
        43.2630, -2.9350;
        43.2308, -2.8379;
        43.1947, -2.7332;
        43.1836, -2.4756;
        43.2843, -2.1697;
        43.3183, -1.9812
    ];

    ruta_donostia_vitoria = [
        43.3183, -1.9812;
        43.2622, -2.0526;
        43.1517, -2.2419;
        43.0650, -2.4937;
        42.9631, -2.6133;
        42.8742, -2.6547;
        42.8467, -2.6716
    ];

    dibujar_ruta_realista(gx, ruta_vitoria_bilbao, [0.9 0 0], 2, 'Backbone ROADM');
    dibujar_ruta_realista(gx, ruta_bilbao_donostia, [0.9 0 0], 2);
    dibujar_ruta_realista(gx, ruta_donostia_vitoria, [0.9 0 0], 2);

    % Nodos
    first_roadm = true;
    first_foadm = true;

    for i = 1:height(T)
        lat = T.Lat(i);
        lon = T.Lon(i);
        nombre = T.Nombre{i};

        % Mayor tamaño para las tres principales
        if ismember(nombre, {'Vitoria-Gasteiz','Bilbao','Donostia'})
            label_font = 12;
        else
            label_font = 8;
        end

        if T.isROADM(i)
            if first_roadm
                geoplot(gx, lat, lon, 'p', 'MarkerSize', 14, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5, 'DisplayName', 'ROADM Node');
                first_roadm = false;
            else
                geoplot(gx, lat, lon, 'p', 'MarkerSize', 14, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5, 'HandleVisibility', 'off');
            end
            text(gx, lat+0.01, lon, [' ' nombre ' (ROADM)'], 'FontSize', label_font, 'FontWeight', 'bold', 'Color', 'r', 'BackgroundColor', [1 1 1 0.7]);
        elseif T.isFOADM(i)
            if first_foadm
                geoplot(gx, lat, lon, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'FOADM Node');
                first_foadm = false;
            else
                geoplot(gx, lat, lon, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'LineWidth', 1, 'HandleVisibility', 'off');
            end
            text(gx, lat+0.005, lon, [' ' nombre], 'FontSize', label_font, 'Color', 'b');
        end
    end

    % Estrellita para Data Center en Amorebieta (aprox)
    lat_dc = 43.1947;
    lon_dc = -2.7332;
    geoplot(gx, lat_dc, lon_dc, '*', 'MarkerSize', 14, 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5, 'DisplayName', 'Data Center');
    text(gx, lat_dc+0.008, lon_dc, ' DC Node', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'm', 'BackgroundColor', [1 1 1 0.7]);

    % Leyenda mejorada
    leg = legend(gx, 'Location', 'southwest');
    leg.FontSize = 14;
    leg.Title.String = 'Network Elements';

    annotation('textbox', [0.15, 0.05, 0.3, 0.05], 'String', 'x21 Provincial rings across the territory', 'FontSize', 10, 'EdgeColor', 'none', 'BackgroundColor', [1 1 1 0.7]);

    % Exportar como SVG
    print(fig, 'euskonect_aggregation_layer', '-dsvg');
end

function dibujar_ruta_realista(gx, ruta, color, grosor, displayName)
    if nargin < 5
        displayName = '';
        visibility = 'off';
    else
        visibility = 'on';
    end

    for i = 1:size(ruta, 1)-1
        num_pts = 30;
        lat_pts = linspace(ruta(i,1), ruta(i+1,1), num_pts);
        lon_pts = linspace(ruta(i,2), ruta(i+1,2), num_pts);

        lat_pts = lat_pts + randn(1, num_pts) * 0.0003;
        lon_pts = lon_pts + randn(1, num_pts) * 0.0003;

        lat_pts = smoothdata(lat_pts, 'gaussian', 7);
        lon_pts = smoothdata(lon_pts, 'gaussian', 7);

        if i == 1 && ~isempty(displayName)
            geoplot(gx, lat_pts, lon_pts, '-', 'LineWidth', grosor, 'Color', color, ...
                    'DisplayName', displayName, 'HandleVisibility', visibility);
        else
            geoplot(gx, lat_pts, lon_pts, '-', 'LineWidth', grosor, 'Color', color, ...
                    'HandleVisibility', 'off');
        end
    end

    ell = referenceEllipsoid('wgs84');
    distancia_total = 0;
    for i = 1:size(ruta, 1)-1
        distancia_total = distancia_total + distance(ruta(i,1), ruta(i,2), ruta(i+1,1), ruta(i+1,2), ell) / 1000;
    end

    mid_idx = ceil(size(ruta, 1) / 2);
    text(gx, ruta(mid_idx,1), ruta(mid_idx,2), sprintf('%.0f km', distancia_total), ...
         'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', [1 1 1 0.7]);
end
