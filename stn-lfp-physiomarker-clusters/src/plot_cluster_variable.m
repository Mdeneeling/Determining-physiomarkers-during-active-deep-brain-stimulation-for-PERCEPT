function fig = plot_cluster_variable(values, idx, colors, name)
%PLOT_CLUSTER_VARIABLE Box and swarm chart of one variable per cluster.

clusters = unique(idx(:))';
fig = figure('Color', 'white');
hold on
for j = 1:numel(clusters)
    x = values(idx == clusters(j));
    x = x(~isnan(x));
    if isempty(x)
        continue
    end
    col = colors(mod(j - 1, size(colors, 1)) + 1, :);
    g = repmat(clusters(j), size(x));
    boxchart(g, x, 'BoxFaceColor', col, 'BoxFaceAlpha', 0.4, 'LineWidth', 1.5, ...
             'MarkerStyle', 'none');
    swarmchart(g, x, 40, col, 'filled', 'MarkerFaceAlpha', 0.5, 'XJitterWidth', 0.3);
end
hold off
xticks(clusters);
xlabel('Cluster');
ylabel(name, 'Interpreter', 'none');
title(name, 'Interpreter', 'none');
set(gca, 'FontSize', 20);
end
