function edge_network
    close all; clc;

    % Figura base (diagrama esquemático, no georreferenciado)
    figure('Color','w','Position',[100 100 900 600]);
    ax = axes;
    axis off;
    hold on;

    % Posiciones simuladas para el diagrama
    pos = struct();
    pos.city1 = [2, 8];   % Bilbao
    pos.city2 = [5, 5];   % Donostia
    pos.city3 = [8, 2];   % Vitoria

    % Dibujar ciudades principales
    plot(pos.city1(1), pos.city1(2), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
    text(pos.city1(1), pos.city1(2)+0.4, 'Bilbao', 'HorizontalAlignment','center', 'FontWeight','bold');

    plot(pos.city2(1), pos.city2(2), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
    text(pos.city2(1), pos.city2(2)+0.4, 'Donostia', 'HorizontalAlignment','center', 'FontWeight','bold');

    plot(pos.city3(1), pos.city3(2), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
    text(pos.city3(1), pos.city3(2)+0.4, 'Vitoria', 'HorizontalAlignment','center', 'FontWeight','bold');

    % Small Cells (3.5 GHz)
    plot(2.5, 7.3, 'ro', 'MarkerSize', 8, 'MarkerFaceColor','r');
    text(2.5, 7.6, 'Small Cell', 'FontSize',8);

    plot(5.5, 4.5, 'ro', 'MarkerSize', 8, 'MarkerFaceColor','r');
    plot(7.5, 1.5, 'ro', 'MarkerSize', 8, 'MarkerFaceColor','r');

    % Macro Cells (700 MHz)
    plot(1.5, 8.5, '^b', 'MarkerSize', 9, 'MarkerFaceColor','b');
    text(1.5, 8.8, 'Macro Cell', 'FontSize',8);

    % mmWave cells (26 GHz)
    plot(2.2, 7.8, '*', 'MarkerSize', 9, 'Color', [1 0.5 0]);
    text(2.2, 8.1, 'mmWave', 'FontSize',8);

    % Edge DCs
    plot(4, 6.5, 's', 'MarkerSize', 10, 'MarkerFaceColor','m', 'MarkerEdgeColor','k');
    text(4, 6.8, 'Edge DC', 'HorizontalAlignment','center', 'FontWeight','bold', 'Color', 'm');

    % Líneas entre elementos (enlaces lógicos)
    line([2 2.5], [8 7.3], 'Color','k','LineStyle','--');
    line([2.5 2.2], [7.3 7.8], 'Color','k','LineStyle','--');
    line([1.5 2], [8.5 8], 'Color','b');

    % Leyenda
    legend({'Ciudad','Small Cell (3.5 GHz)','Macro Cell (700 MHz)','mmWave (26 GHz)','Edge DC'}, ...
        'Location','southoutside','Orientation','horizontal','FontSize',9);

    title('Edge Network - Access Layer Sketch','FontSize',14,'FontWeight','bold');
end
