function fig = plot_clusters_pca(Xz, idx, colors, title_text)
%PLOT_CLUSTERS_PCA Clusters in the space of the first two principal components.
%
%   fig = PLOT_CLUSTERS_PCA(Xz, idx, colors, title_text) projects the
%   z-scored clustering variables onto PC1 and PC2, colours observations by
%   cluster and shades each cluster's convex hull.

[~, score, ~, ~, explained] = pca(Xz);
clusters = unique(idx(:))';

fig = figure('Color', 'white');
hold on
h = gobjects(numel(clusters), 1);
for j = 1:numel(clusters)
    pts = score(idx == clusters(j), 1:2);
    col = colors(mod(j - 1, size(colors, 1)) + 1, :);
    if size(pts, 1) >= 3 && rank(pts - mean(pts, 1)) == 2
        K = convhull(pts(:, 1), pts(:, 2));
        fill(pts(K, 1), pts(K, 2), col, 'FaceAlpha', 0.15, 'EdgeColor', 'none', ...
             'HandleVisibility', 'off');
    end
    h(j) = scatter(pts(:, 1), pts(:, 2), 40, col, 'filled');
end
hold off
xlabel(sprintf('PC1 (%.0f%% of variance)', explained(1)));
ylabel(sprintf('PC2 (%.0f%% of variance)', explained(2)));
title(title_text, 'Interpreter', 'none');
legend(h, "Cluster " + string(clusters), 'Location', 'best');
legend boxoff
axis equal
grid on
set(gca, 'FontSize', 20);
end
