function fig = plot_k_selection(k_range, total_sumd, silhouettes)
%PLOT_K_SELECTION Elbow and silhouette plots for choosing k.
%
%   The silhouette panel shows the mean silhouette value per k with a
%   shaded band of +/- 1 SD across observations.

fig = figure('Color', 'white', 'Position', [100 100 1100 450]);

subplot(1, 2, 1);
plot(k_range, total_sumd, '-o', 'LineWidth', 1.5, 'Color', 'k');
xlabel('Number of clusters k');
ylabel('Total within-cluster sum of squares');
title('Elbow method');
set(gca, 'FontSize', 16, 'XTick', k_range);
box off

subplot(1, 2, 2);
m = mean(silhouettes, 1);
s = std(silhouettes, 0, 1);
hold on
fill([k_range, fliplr(k_range)], [m + s, fliplr(m - s)], 'k', ...
     'FaceAlpha', 0.15, 'EdgeColor', 'none');
plot(k_range, m, '-', 'LineWidth', 3, 'Color', 'k');
hold off
xlabel('Number of clusters k');
ylabel('Silhouette value (mean \pm SD)');
title('Silhouette method');
set(gca, 'FontSize', 16, 'XTick', k_range);
box off
end
