function [total_sumd, silhouettes] = k_selection(Xz, k_range, replicates)
%K_SELECTION Within-cluster sum of squares and silhouette values per k.
%
%   [total_sumd, silhouettes] = K_SELECTION(Xz, k_range, replicates) runs
%   k-means for every k in k_range (k >= 2) on Xz and returns the total
%   within-cluster sum of squared distances (elbow method) and the
%   silhouette value of every observation ([observations x numel(k_range)]).

total_sumd = nan(numel(k_range), 1);
silhouettes = nan(size(Xz, 1), numel(k_range));
for j = 1:numel(k_range)
    [idx, ~, sumd] = kmeans(Xz, k_range(j), 'Replicates', replicates, 'Start', 'plus');
    total_sumd(j) = sum(sumd);
    silhouettes(:, j) = silhouette(Xz, idx);
end
end
