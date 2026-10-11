function [idx, centroids, Xz] = run_kmeans(X, k, replicates)
%RUN_KMEANS k-means on z-scored variables with reproducible cluster labels.
%
%   [idx, centroids, Xz] = RUN_KMEANS(X, k, replicates) z-scores the columns
%   of X ([observations x variables]), runs k-means (k-means++ start,
%   squared Euclidean distance, best of `replicates` runs) and relabels
%   the clusters in ascending order of their centroid on the first
%   variable, so labels do not depend on the random start. Set the seed
%   with RNG for reproducibility. centroids are in z-units.

Xz = zscore(X);
[idx, centroids] = kmeans(Xz, k, 'Replicates', replicates, 'Start', 'plus');

[~, order] = sort(centroids(:, 1));
new_label(order) = 1:k;
idx = reshape(new_label(idx), [], 1);
centroids = centroids(order, :);
end
